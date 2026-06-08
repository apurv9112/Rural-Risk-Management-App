import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
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
                controller.selectedAgeValue = null;
                controller.selectedbreedValue = null;
                controller.selectedbodycolorValue = null;
                controller.selectedrighthornValue = null;
                controller.selectedlefthornValue = null;
                controller.updateSumInsuredBySpecies(value);
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
              value: controller.selectedAgeValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.ageFocusNode,
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
              value: controller.selectedbreedValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.breedFocusNode,
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
              value: controller.selectedbodycolorValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.bodyColorFocusNode,
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
              value: controller.selectedrighthornValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.rightHornFocusNode,
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
              value: controller.selectedlefthornValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.leftHornFocusNode,
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
              value: controller.selectedtailcolorValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.tailColorFocusNode,
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
              value: controller.selectedidmarkValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.idMarkFocusNode,
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
                focusNode: controller.milkLitterFocusNode,
                validator: controller.isSuccessfullyTagging
                    ? MultiValidator([
                        RequiredValidator(errorText: "Required")
                      ])
                    : null,
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
                controller.selectedlactationValue = value.toString();
              },
              value: controller.selectedlactationValue,
              validator: (value) => controller.isSuccessfullyTagging && (value == null || value.isEmpty) ? "Required" : null,
              focusNode: controller.lactationFocusNode,
            ),
          ),
        ],
      ),
    ],
  );
}
