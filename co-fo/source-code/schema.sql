create extension if not exists "uuid-ossp";

create or replace function uuid_generate_v7()
    returns uuid
as
$$
begin
    return encode(
            set_bit(
                    set_bit(
                            overlay(uuid_send(gen_random_uuid())
                                    placing
                                    substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from
                                              3)
                                    from 1 for 6
                            ),
                            52, 1
                    ),
                    53, 1
            ),
            'hex')::uuid;
end
$$
    language plpgsql
    volatile;

  

create type user_type as enum ('ideator','builder');
create table if not exists profiles (
    user_id uuid primary key references auth.users(id) on delete cascade, 
    user_type user_type default 'ideator' not null,  
    bio text,             
    skills text[],          
    avatar text,           
    title varchar(100)       
);


create table if not exists community_posts (
    id uuid primary key default uuid_generate_v7(),  
    user_id uuid references profiles(user_id) on delete cascade, 
    tag varchar(50),     
    title text,
    description text,
    like_count integer default 0,
    comment_count integer default 0,
    created_at timestamptz default now(), 
    updated_at timestamptz default now()
);


create table swipes (
  id           uuid       primary key default uuid_generate_v7(),
  swiper_id    uuid       not null references profiles(user_id) on delete cascade,
  swipee_id    uuid       not null references profiles(user_id) on delete cascade,
  liked        boolean    not null,            
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique(swiper_id, swipee_id)
);

create table chat_threads (
  id         uuid primary key default uuid_generate_v7(),
  user_a     uuid not null references profiles(user_id) on delete cascade,
  user_b     uuid not null references profiles(user_id) on delete cascade,
  match_key  text generated always as (
    least(user_a::text, user_b::text) || ':' || greatest(user_a::text, user_b::text)
  ) stored,
  created_at timestamptz not null default now(),
  unique (match_key)
);
alter table chat_threads enable row level security;

create policy "Users can subscribe to their chat_threads"
on chat_threads
for select
using (
  auth.uid()::uuid = user_a or auth.uid()::uuid = user_b
);


create policy "Functions/triggers can access chat_threads"
on chat_threads
for all
using (
  auth.role() = 'service_role' 
  or auth.uid()::uuid = user_a
  or auth.uid()::uuid = user_b
);


create table messages (
  id          uuid primary key default uuid_generate_v7(),
  thread_id   uuid not null references chat_threads(id) on delete cascade,
  sender_id   uuid not null references profiles(user_id) on delete cascade,
  content     text not null,
  media text[],
  read_by uuid[],
  created_at  timestamptz not null default now()
);
create index idx_messages_thread_id_created_at on messages(thread_id, created_at desc);



create table if not exists likes (
    id uuid primary key default uuid_generate_v7(),  
    user_id uuid references profiles(user_id) on delete cascade,  
    post_id uuid references community_posts(id) on delete cascade  
);


create table if not exists comments (
    id uuid primary key default uuid_generate_v7(),  
    user_id uuid references profiles(user_id) on delete cascade,  
    post_id uuid references community_posts(id) on delete cascade,  
    comment_text text not null,   
    created_at timestamptz default now()
);


create or replace function update_like_count() returns trigger as $$
begin
  if (tg_op = 'INSERT') then
    update community_posts set like_count = like_count + 1
      where id = new.post_id;
    return new;
  elsif (tg_op = 'DELETE') then
    update community_posts set like_count = like_count - 1
      where id = old.post_id;
    return old;
  end if;
  return null; 
end;
$$ language plpgsql;


create trigger trg_update_like_count_insert
after insert on likes
for each row execute function update_like_count();

create trigger trg_update_like_count_delete
after delete on likes
for each row execute function update_like_count();



create or replace function update_comment_count() returns trigger as $$
begin
  if (tg_op = 'INSERT') then
    update community_posts set comment_count = comment_count + 1
      where id = new.post_id;
    return new;
  elsif (tg_op = 'DELETE') then
    update community_posts set comment_count = comment_count - 1
      where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$ language plpgsql;


create trigger trg_update_comment_count_insert
after insert on comments
for each row execute function update_comment_count();

create trigger trg_update_comment_count_delete
after delete on comments
for each row execute function update_comment_count();



create or replace function toggle_like(user_id uuid, post_id uuid)
returns void as $$
begin
  if exists (select 1 from likes where likes.user_id = toggle_like.user_id and likes.post_id = toggle_like.post_id) then
    delete from likes where likes.user_id = toggle_like.user_id and likes.post_id = toggle_like.post_id;
  else
    insert into likes (user_id, post_id) values (toggle_like.user_id, toggle_like.post_id);
  end if;
end;
$$ language plpgsql;

DROP VIEW IF EXISTS community_posts_with_likes;
create or replace view community_posts_with_likes as
select
  cp.*,
  exists (
    select 1
    from likes l
    where l.post_id = cp.id
      and l.user_id = auth.uid()
  ) as has_liked
from community_posts cp;

DROP VIEW IF EXISTS user_community_posts_with_likes;
create or replace view user_community_posts_with_likes as
select
  cp.*,
  exists (
    select 1
    from likes l
    where l.post_id = cp.id
      and l.user_id = auth.uid()
  ) as has_liked
from community_posts cp where user_id = auth.uid();



create or replace function update_swipes_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_swipes_modtime
before update on swipes
for each row execute function update_swipes_timestamp();


create or replace function handle_new_swipe()
returns trigger as $$
begin
  if (new.liked) then
    if exists (
      select 1 from swipes s
      where s.swiper_id = new.swipee_id
        and s.swipee_id = new.swiper_id
        and s.liked = true
    ) then
      insert into chat_threads (user_a, user_b)
      values (
        least(new.swiper_id, new.swipee_id),
        greatest(new.swiper_id, new.swipee_id)
      )
      on conflict do nothing;
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_on_swipe
after insert on swipes
for each row execute function handle_new_swipe();


create or replace function get_discoverable_users(_me uuid, _utype text)
returns table (
  user_id   uuid,
  username text,
  user_type user_type,
  bio       text,
  skills    text[],
  avatar    text,
  title     varchar
) language sql stable as $$
  select p.user_id, p.username, p.user_type, p.bio, p.skills, p.avatar, p.title
    from profiles p
   where p.user_id != _me
     and p.user_type = _utype::user_type
     and not exists (
       select 1
         from swipes s
        where s.swiper_id = _me
          and s.swipee_id = p.user_id
     );
$$;



create or replace function swipe_user(
  _swiper uuid,
  _swipee uuid,
  _liked boolean
) returns void language plpgsql as $$
begin
  insert into swipes (swiper_id, swipee_id, liked)
    values (_swiper, _swipee, _liked)
  on conflict (swiper_id, swipee_id)
    do update set liked      = excluded.liked,
                  updated_at = now();
end;
$$;

create or replace function get_user_chat_threads(_me uuid)
returns table (
  thread_id     uuid,
  other_user_id uuid,
  user_type     user_type,
  avatar        text,
  title         varchar,
  username      text,
  last_message  text,
  last_sender   uuid,
  last_sent_at  timestamptz,
  unread_count  integer
)
language sql
stable
as $$
  select distinct on (ct.id)
    ct.id as thread_id,
    case 
      when ct.user_a = _me then ct.user_b
      else ct.user_a
    end as other_user_id,
    p.user_type,
    p.avatar,
    p.title,
    p.username,
    m.content as last_message,
    m.sender_id as last_sender,
    m.created_at as last_sent_at,
    coalesce((
      select count(*) 
      from messages msg 
      where msg.thread_id = ct.id
        and msg.sender_id != _me
        and not (_me = any(msg.read_by))
    ), 0) as unread_count
  from chat_threads ct
  join profiles p on p.user_id = case 
    when ct.user_a = _me then ct.user_b
    else ct.user_a
  end
  left join lateral (
    select m.content, m.sender_id, m.created_at
    from messages m
    where m.thread_id = ct.id
    order by m.created_at desc
    limit 1
  ) m on true
  where ct.user_a = _me or ct.user_b = _me
  order by ct.id, m.created_at desc nulls last;
$$;


create or replace function send_message(
  _thread_id uuid,
  _sender_id uuid,
  _content text,
  _media text[] default null
)
returns table (
  message_id uuid,
  thread_id uuid,
  sender_id uuid,
  content text,
  media text[],
  created_at timestamptz
)
language plpgsql
as $$
begin
  return query
  insert into messages (thread_id, sender_id, content, media)
  values (_thread_id, _sender_id, _content, _media)
  returning
    id as message_id,
    messages.thread_id,
    messages.sender_id,
    messages.content,
    messages.media,
    messages.created_at;
end;
$$;


create or replace function get_thread_messages(
  _me uuid,
  _thread_id uuid,
  _limit int default 50,
  _offset int default 0
)
returns table (
  message_id uuid,
  sender_id uuid,
  content text,
  media text[],
  created_at timestamptz,
  is_read boolean
)
language sql
stable
as $$
  select
    m.id as message_id,
    m.sender_id,
    m.content,
    m.media,
    m.created_at,
    _me = any(m.read_by) as is_read
  from messages m
  where m.thread_id = _thread_id
  order by m.created_at desc
  limit _limit
  offset _offset;
$$;


create or replace function mark_thread_as_read(_me uuid, _thread_id uuid)
returns void
language plpgsql
as $$
begin
  update messages
  set read_by = array_append(read_by, _me)
  where thread_id = _thread_id
    and sender_id != _me
    and not (_me = any(read_by));
end;
$$;




CREATE POLICY "Enable read access for all users" ON "storage"."objects"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable insert for all users" ON "storage"."objects"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON "storage"."objects"
AS PERMISSIVE FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete for all users" ON "storage"."objects"
AS PERMISSIVE FOR DELETE
TO public
USING (true);

CREATE POLICY "Enable read access for all users" ON "storage"."buckets"
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable insert for all users " ON "storage"."buckets"
AS PERMISSIVE FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON "storage"."buckets"
AS PERMISSIVE FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete for all users" ON "storage"."buckets"
AS PERMISSIVE FOR DELETE
TO public
USING (true);