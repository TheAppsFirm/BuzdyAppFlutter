import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/presentation/screens/dashboard/products/model/productModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // Construct image URL or use placeholder
    final imageUrl = (product.image != null && product.image!.isNotEmpty)
        ? (product.image!.contains('http')
            ? product.image
            : "https://portal.buzdy.com/storage/admin/uploads/images/${product.image}")
        : null;
    // Carousel with single image or placeholder
    final imageUrls = imageUrl != null ? [imageUrl] : ["assets/images/placeholder.png"];

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: appBarrWitoutAction(
        title: product.name ?? "Product Details",
        leadinIconColor: Colors.blueAccent, // Match appButtonColor from sample
        leadinBorderColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Slider
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180.0,
                    autoPlay: imageUrls.length > 1, // Auto-play only if multiple images
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.7,
                  ),
                  items: imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: url.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Image.asset(
                                    "assets/images/placeholder.png",
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  url,
                                  fit: BoxFit.cover,
                                ),
                        );
                      },
                    );
                  }).toList(),
                ),
                UIHelper.verticalSpaceSm20,

                // Product Name
                kText(
                  text: "Product",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: product.name ?? "Unknown Product",
                  fWeight: fontWeightRegular,
                  fSize: 16.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Description
                kText(
                  text: "Overview",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: product.description.isNotEmpty
                      ? product.description
                      : "No description available.",
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  height: 1.2,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Average Rating
                kText(
                  text: "Average Rating",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: "${product.avgRating ?? 0}/5",
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.green,
                ),
                UIHelper.verticalSpaceSm20,

                // Product Type
                kText(
                  text: "Type",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: product.productableType == "App\\Models\\Merchant"
                      ? "Merchant"
                      : product.productableType == "App\\Models\\Bank"
                          ? "Bank"
                          : "Unknown",
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Phone
                kText(
                  text: "Phone",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: product.phone.isNotEmpty ? product.phone : "N/A",
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,

                // Category ID (Optional)
                kText(
                  text: "Category",
                  fWeight: fontWeightBold,
                  fSize: 18.0,
                ),
                UIHelper.verticalSpaceSm5,
                kText(
                  text: product.categoryId != 0
                      ? "Category ID: ${product.categoryId}"
                      : "N/A",
                  fWeight: fontWeightRegular,
                  fSize: 14.0,
                  tColor: Colors.grey[700],
                ),
                UIHelper.verticalSpaceSm20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}