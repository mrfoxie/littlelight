import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';

class ItemMainInfoWidget extends BaseDestinyStatefulItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  State<StatefulWidget> createState() {
    return ItemMainInfoWidgetState();
  }
}

class ItemMainInfoWidgetState extends BaseDestinyItemState<ItemMainInfoWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(definition?.itemTypeDisplayName ?? ""),
              Padding(
                  padding: EdgeInsets.only(top: 8), child: primaryStat(context))
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                definition.displayProperties.description,
              )),
          buildWishListInfo(context),
          buildLockInfo(context),
        ]));
  }

  Widget buildLockInfo(BuildContext context) {
    if (item?.lockable != true) return Container();
    var locked = item?.state?.contains(ItemState.Locked);
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Icon(locked ? FontAwesomeIcons.lock : FontAwesomeIcons.unlock,
                size: 14),
            Container(
              width: 4,
            ),
            Expanded(
                child: locked
                    ? TranslatedTextWidget("Item Locked", uppercase: true,)
                    : TranslatedTextWidget("Item Unlocked", uppercase: true,)),
            RaisedButton(
              child: locked
                  ? TranslatedTextWidget("Unlock", uppercase: true,)
                  : TranslatedTextWidget("Lock", uppercase:  true,),
              onPressed: () async {
                var itemWithOwner = ItemWithOwner(item, characterId);
                InventoryService().changeLockState(itemWithOwner, !locked);
                setState((){});
              },
            )
          ],
        ));
  }

  Widget buildWishListInfo(BuildContext context) {
    var tags = WishlistsService().getWishlistBuildTags(item);
    if (tags == null) return Container();
    if (tags.contains(WishlistTag.GodPVE) &&
        tags.contains(WishlistTag.GodPVP)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(
                tags: [WishlistTag.GodPVE, WishlistTag.GodPVP].toSet()),
            Container(
              width: 8,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This item is considered a godroll for both PvE and PvP."))
          ]));
    }
    var rows = <Widget>[];
    if (tags.contains(WishlistTag.GodPVE)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.GodPVE].toSet()),
        Container(
          width: 8,
        ),
        Expanded(
            child:
                TranslatedTextWidget("This item is considered a PvE godroll."))
      ])));
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.GodPVP].toSet()),
        Container(
          width: 8,
        ),
        Expanded(
            child:
                TranslatedTextWidget("This item is considered a PvP godroll."))
      ])));
    }
    if (tags.contains(WishlistTag.PVE) &&
        tags.contains(WishlistTag.PVP) &&
        rows.length == 0) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(
                tags: [WishlistTag.PVE, WishlistTag.PVP].toSet()),
            Container(
              width: 8,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This item is considered a good roll for both PvE and PvP."))
          ]));
    }
    if (tags.contains(WishlistTag.PVE) && !tags.contains(WishlistTag.GodPVE)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.PVE].toSet()),
        Container(
          width: 8,
        ),
        Expanded(
            child: TranslatedTextWidget(
                "This item is considered a good roll for PVE."))
      ])));
    }
    if (tags.contains(WishlistTag.PVP) && !tags.contains(WishlistTag.GodPVP)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.PVP].toSet()),
        Container(
          width: 8,
        ),
        Expanded(
            child: TranslatedTextWidget(
                "This item is considered a good roll for PVP."))
      ])));
    }
    if (tags.contains(WishlistTag.Bungie)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.Bungie].toSet()),
        Container(
          width: 8,
        ),
        Expanded(
            child: TranslatedTextWidget("This item is a Bungie curated roll."))
      ])));
    }
    if (rows.length > 0) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Column(
            children: rows,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ));
    }
    if (tags.contains(WishlistTag.Trash)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: [WishlistTag.Trash].toSet()),
            Container(
              width: 8,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This item is considered a trash roll."))
          ]));
    }
    if (tags.length == 0) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgeWidget(tags: Set()),
            Container(
              width: 8,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This item is considered an uncategorized godroll."))
          ]));
    }
    return Container();
  }

  Widget primaryStat(context) {
    return PrimaryStatWidget(
      definition: definition,
      instanceInfo: instanceInfo,
      suppressLabel: true,
      fontSize: 36,
    );
  }
}
