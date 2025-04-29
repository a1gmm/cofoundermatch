import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/bottom_nav/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Find Co-Founders'),
          bottom: TabBar(
            physics: NeverScrollableScrollPhysics(),
            unselectedLabelColor: Colors.grey,
            labelColor: Theme.of(context).primaryColor,
            labelStyle: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontSize: 16),
            indicatorColor: Theme.of(context).primaryColor,
            labelPadding: EdgeInsets.zero,
            tabs: [Tab(child: Text('Ideators')), Tab(child: Text('Builders'))],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            BlocProvider(
              create: (_) => ListMembersCubit()..list(userType: 'ideator'),
              child: HomeCardsScreen(),
            ),
            BlocProvider(
              create: (_) => ListMembersCubit()..list(userType: 'builder'),
              child: HomeCardsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCardsScreen extends StatefulWidget {
  const HomeCardsScreen({super.key});

  @override
  State<HomeCardsScreen> createState() => _HomeCardsScreenState();
}

class _HomeCardsScreenState extends State<HomeCardsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Widget> cards = [];
  double cardSize = 0.7.sh;
  int pageNumber = 1;

  final CardSwiperController controller = CardSwiperController();

  _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ListMembersCubit, ListMembersState>(
      listener: (context, state) {
        if (state is ListMembersSuccess) {
          if (state.response.length > 0) {
            cards = List<Widget>.generate(state.response.length, (int index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          state.response[index]['avatar'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Card(
                              margin: EdgeInsets.zero,
                              color: Theme.of(context).primaryColor,
                              // child: SizedBox.expand(
                              //   child: Center(
                              //     child: Text(
                              //       state.response[index]['username'][0],
                              //       style: Theme.of(
                              //         context,
                              //       ).textTheme.headlineLarge!.copyWith(
                              //         color: Colors.white,
                              //         fontSize: 62,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            );
                          },
                        ),
                      ),
                      // Text overlay
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.response[index]['username'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Chip(
                                    elevation: 0,
                                    backgroundColor: Colors.green.withValues(
                                      alpha: 0.3,
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity(
                                      horizontal: -3,
                                      vertical: -3,
                                    ),
                                    label: Text(
                                      'type',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                state.response[index]['bio'],
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.0,
                                ),
                              ),
                              Gap(4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      children:
                                          (state.response[index]['skills']
                                                  as List<dynamic>)
                                              .map<Widget>((e) {
                                                return Chip(
                                                  backgroundColor: Theme.of(
                                                    context,
                                                  ).primaryColor.withAlpha(30),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity: VisualDensity(
                                                    horizontal: -3,
                                                    vertical: -3,
                                                  ),
                                                  label: Text(
                                                    e.toString(),
                                                    style: TextStyle(
                                                      color:
                                                          Theme.of(
                                                            context,
                                                          ).primaryColor,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ).pOnly(right: 2);
                                              })
                                              .toList(),
                                    ),
                                  ),
                                ],
                              ),

                              Gap(4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      visualDensity: VisualDensity.comfortable,
                                    ),
                                    onPressed:
                                        () => context.pushNamed(
                                          AppRouter.memberDetailScreen,
                                          extra: state.response[index],
                                        ),
                                    child: Text('View details'),
                                  ),
                                  FilledButton.icon(
                                    onPressed: () {},
                                    iconAlignment: IconAlignment.end,
                                    style: FilledButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                    label: Text('Interested'),
                                    icon: Icon(Symbols.favorite),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }
        }
      },
      builder:
          (context, state) => switch (state) {
            ListMembersSuccess() =>
              state.response.isEmpty || cards.isEmpty
                  ? Text('No members for you').centered()
                  : SizedBox(
                    height: cardSize,
                    child: CardSwiper(
                      controller: controller,
                      numberOfCardsDisplayed: cards.length,
                      cardsCount: state.response.length,
                      cardBuilder:
                          (
                            context,
                            index,
                            horizontalThresholdPercentage,
                            verticalThresholdPercentage,
                          ) => cards[index],
                      isDisabled: false,
                      isLoop: false,
                      allowedSwipeDirection: AllowedSwipeDirection.only(
                        left: true,
                        right: true,
                      ),
                      onSwipe: (
                        int previousIndex,
                        int? currentIndex,
                        CardSwiperDirection direction,
                      ) {
                        if (direction.name.toLowerCase() == 'right') {
                          context.read<SwipeMembersCubit>().swipe(
                            swipeeId: state.response[previousIndex]['user_id'],
                            liked: true,
                          );
                        } else if (direction.name.toLowerCase() == 'left') {
                          context.read<SwipeMembersCubit>().swipe(
                            swipeeId: state.response[previousIndex]['user_id'],
                            liked: false,
                          );
                        }
                        return true;
                      },
                      onEnd: () {
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              title: Text('No new users'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                    cards = [];
                                    _onChanged();
                                  },
                                  child: Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                        // controller.moveTo(0);
                      },
                    ),
                  ),

            _ => context.isBusy(context).centered(),
          },
    );
  }
}
