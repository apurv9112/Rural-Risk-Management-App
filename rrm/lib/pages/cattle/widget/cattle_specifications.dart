import 'package:flutter/material.dart';
import 'package:rrm/pages/cattle/widget/custom_dropdown.dart';
import 'package:rrm/utils/colors.dart';
import 'package:rrm/utils/responsive.dart';
import 'package:rrm/widgets/text_field.dart';

iscattlespecifications({required BuildContext context, required controller}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Species',
              value: controller.selectedSpeciesValue,
              items: (controller.speciesItems as List<String>)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.selectedSpeciesValue = value.toString();
                print("aaaa ::: ${controller.selectedSpeciesValue}");
                controller.update();
              },
            ),
          ),
          SizedBox(width: wp(2)),
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Age',
              items: controller.selectedSpeciesValue == "Buffalo"
                  ? (controller.ageBuffaloCow as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Cow"
                  ? (controller.ageBuffaloCow as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Sheep"
                  ? (controller.ageSheepGoat as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : (controller.ageSheepGoat as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
              onChanged: (value) {
                controller.selectedAgeValue = value.toString();
              },
            ),
          ),
        ],
      ),
      SizedBox(height: hp(1)),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Breed',
              items: controller.selectedSpeciesValue == "Buffalo"
                  ? (controller.breedItemsBuffalo as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Cow"
                  ? (controller.breedItemsCow as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Sheep"
                  ? (controller.breedItemsSheep as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : (controller.breedItemsGoat as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),

              onChanged: (value) {
                controller.selectedbreedValue = value.toString();
              },
            ),
          ),
          SizedBox(width: wp(2)),
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Body Color',
              items: controller.selectedSpeciesValue == "Buffalo"
                  ? (controller.bodycolorItemsBuffalo as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Cow"
                  ? (controller.bodycolorItemsCow as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Sheep"
                  ? (controller.bodycolorItemsSheep as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : (controller.bodycolorItemsGoat as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),

              onChanged: (value) {
                controller.selectedbodycolorValue = value.toString();
              },
            ),
          ),
        ],
      ),
      SizedBox(height: hp(1)),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Right Horn',
              items: controller.selectedSpeciesValue == "Buffalo"
                  ? (controller.righthornItemsBuffalo as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Cow"
                  ? (controller.righthornItemsCow as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Sheep"
                  ? (controller.righthornItemsSheep as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : (controller.righthornItemsGoat as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),

              onChanged: (value) {
                controller.selectedrighthornValue = value.toString();
              },
            ),
          ),
          SizedBox(width: wp(2)),
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Left Horn',
              items: controller.selectedSpeciesValue == "Buffalo"
                  ? (controller.lefthornItemsBuffalo as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Cow"
                  ? (controller.lefthornItemsCow as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : controller.selectedSpeciesValue == "Sheep"
                  ? (controller.lefthornItemsSheep as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList()
                  : (controller.lefthornItemsGoat as List<String>)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),

              onChanged: (value) {
                controller.selectedlefthornValue = value.toString();
              },
            ),
          ),
        ],
      ),
      SizedBox(height: hp(1)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Tail Color',
              items: (controller.tailcolorItems as List<String>)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.selectedtailcolorValue = value.toString();
              },
            ),
          ),
          SizedBox(width: wp(2)),
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Id Mark',
              items: (controller.idmarkItems as List<String>)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.selectedidmarkValue = value.toString();
              },
            ),
          ),
        ],
      ),
      SizedBox(height: hp(1)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: hp(5.5),
              child: CustomTextField(
                controller: controller.milklittercontroller,

                hint: "Milk L/Day",
                hintStyle: TextStyle(
                  color: AppColors.DARK,
                  fontWeight: FontWeight.w500,
                  fontSize: dp(context, 12),
                ),
                keyboardType: TextInputType.number,
                backgroundColor: AppColors.WHITE,
                inputtextcolor: AppColors.PRIMARY_COLOR,
                readOnly: false,
                suffixIcon: Icon(
                  Icons.arrow_circle_down_outlined,
                  color: AppColors.PRIMARY_COLOR,
                ),
              ),
            ),
          ),

          SizedBox(width: wp(2)),
          Expanded(
            flex: 3,
            child: customdropdown(
              context: context,
              controller: controller,
              title: 'Lactation',
              items: (controller.lactationItems as List<String>)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.selectedidmarkValue = value.toString();
              },
            ),
          ),
        ],
      ),
    ],
  );
}
