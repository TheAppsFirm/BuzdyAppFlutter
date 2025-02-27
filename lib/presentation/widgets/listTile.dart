import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/text_styles.dart';

class CustomListTIle extends StatefulWidget {
  var leading;
  var title;
  var subtitle;
  var trailing;
  var onTap;
  var time;
  var chatcounting;

  CustomListTIle(
      {super.key,
      this.leading,
      this.title,
      this.subtitle,
      this.time,
      this.trailing,
      this.chatcounting,
      required this.onTap});

  @override
  State<CustomListTIle> createState() => _CustomListTIleState();
}

class _CustomListTIleState extends State<CustomListTIle> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: SizedBox(
            height: Get.height * 0.08,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      child: CircleAvatar(
                          radius: 35, backgroundImage: widget.leading),
                    )),
                Expanded(
                    flex: 4,
                    child: Container(
                      constraints: BoxConstraints(),
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title ?? "Name",
                                      style: textStyleMontserratBold(
                                          color: mainBlackcolor),
                                    ),
                                    Text(
                                      widget.subtitle ?? "this is my channel",
                                      style: textStyleMontserratMiddle(
                                        color: mainBlackcolor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: Get.width * 0.15,
                              decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        widget.time ?? "10:00",
                                        style: textStyleMontserratMiddle(
                                            color: mainBlackcolor),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: 32,
                                        decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text(
                                          widget.chatcounting ?? "12",
                                          style: textStyleMontserratMiddle(
                                              color: Colors.white70),
                                        )),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                    )),
              ],
            ),
          )
          //  ListTile(
          //   onTap: () {
          //     Get.to(
          //         HomeDetail(
          //           model: viewmodel.userList[index],
          //           index: index,
          //         ),
          //         transition: Transition.noTransition);
          //   },
          //   tileColor: whiteColor,
          //   horizontalTitleGap: 0.0,
          //   contentPadding: EdgeInsets.zero,
          //   leading: CircleAvatar(
          //     radius: 35,
          //     backgroundImage: viewmodel.userList[index].image == ""
          //         ? NetworkImage(
          //             "https://i.pinimg.com/originals/a8/57/00/a85700f3c614f6313750b9d8196c08f5.png")
          //         : NetworkImage(viewmodel.userList[index].image),
          //   ),
          //   title: Text(
          //     viewmodel.userList[index].name,
          //     style: TextStyle(
          //         fontSize: 17,
          //         fontWeight: FontWeight.bold,
          //         color: blackColor),
          //   ),
          //   subtitle: Text(
          //     viewmodel.userList[index].subtitle,
          //     style: TextStyle(
          //         fontSize: 17,
          //         fontWeight: FontWeight.normal,
          //         color: blackColor),
          //   ),
          //   trailing: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Text(index.toString()),
          //   ),
          // ),

          ),
    );
  }
}

// simpleListTile Class
class SimpleListTile extends StatefulWidget {
  var leading;
  var title;
  var trailing;
  var subtitle;
  var height;
  var width;
  var tileColor;
  var onTap;
  var contentPadding;
  var tileborderRadius,
      topPaddingtile,
      titlecolor,
      horizontalTitleGap,
      minVerticalPadding,
      leadingHeight,
      leadindWidth;

  SimpleListTile(
      {super.key,
      this.leading,
      this.tileborderRadius,
      this.subtitle,
      this.contentPadding,
      this.horizontalTitleGap,
      this.minVerticalPadding,
      this.title,
      this.height,
      this.width,
      this.trailing,
      this.topPaddingtile,
      this.titlecolor,
      this.leadingHeight,
      this.leadindWidth,
      this.onTap,
      this.tileColor});

  @override
  State<SimpleListTile> createState() => _SimpleListTileState();
}

class _SimpleListTileState extends State<SimpleListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? Get.height * 0.07,
      width: widget.width ?? Get.width,
      decoration: BoxDecoration(
          color: widget.tileColor ?? Colors.transparent,
          borderRadius: widget.tileborderRadius),
      child: Padding(
        padding: widget.topPaddingtile ?? EdgeInsets.zero,
        child: ListTile(
          // visualDensity: VisualDensity(horizontal: 0, vertical: -0),
          horizontalTitleGap: widget.horizontalTitleGap ?? 0.0,
          minVerticalPadding: widget.minVerticalPadding ?? 0.0,
          contentPadding: widget.contentPadding ?? EdgeInsets.zero,
          leading: Container(
            //    color: redColor,
            child: Image(
              image: widget.leading ?? AssetImage("images/p.png"),
              height: 30,
              width: 30,
            ),
          ),
          title: Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Text(
                widget.title ?? "Title",
                style: textStyleMontserratMiddle(
                    fontSize: 15, color: widget.titlecolor ?? mainBlackcolor),
              ),
            ),
          ),
          subtitle: widget.subtitle ??
              Text(
                "",
                style: textStyleMontserratMiddle(
                    fontSize: 14, color: mainBlackcolor),
              ),
          onTap: widget.onTap ?? () {},
          trailing: widget.trailing ??
              SizedBox(
                height: 1,
                width: 1,
              ),
        ),
      ),
    );
  }
}
