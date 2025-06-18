import 'dart:async';
import 'package:buzdy/presentation/screens/dashboard/products/ProductDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:buzdy/presentation/viewmodels/user_view_model.dart';
import 'package:buzdy/core/colors.dart';
import 'package:buzdy/core/ui_helpers.dart';
import 'package:buzdy/presentation/widgets/appBar.dart';
import 'package:buzdy/presentation/widgets/customText.dart';
import 'package:buzdy/core/text_styles.dart';
import 'package:buzdy/presentation/screens/dashboard/products/model/productModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  Timer? _filterDebounce;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<UserViewModel>(context, listen: false);
    print(
        "ProductsScreen: initState - selectedType: ${viewModel.selectedType}, productList length: ${viewModel.productList.length}, isLoadingMore: ${viewModel.productisLoadingMore}");

    // Fetch initial products
    if (viewModel.productList.isEmpty && !viewModel.productisLoadingMore) {
      if (viewModel.selectedType == null) {
        print("ProductsScreen: Fetching all products (page 1)");
        viewModel.getAllProducts(pageNumber: 1);
      } else {
        print(
            "ProductsScreen: Fetching filtered products (type: ${viewModel.selectedType}, page 1)");
        viewModel.getAllProductsWithFilters(
          pageNumber: 1,
          type: viewModel.selectedType!,
        );
      }
    }

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(() {
      if (_debounce?.isActive ?? false) return;
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
          final viewModel =
              Provider.of<UserViewModel>(context, listen: false);
          if (!viewModel.productisLoadingMore &&
              viewModel.producthasMoreData) {
            print(
                "ProductsScreen: Reached bottom, fetching page: ${viewModel.productcurrentPage}, selectedType: ${viewModel.selectedType}");
            if (viewModel.selectedType == null) {
              viewModel.getAllProducts(
                  pageNumber: viewModel.productcurrentPage);
            } else {
              viewModel.getAllProductsWithFilters(
                pageNumber: viewModel.productcurrentPage,
                type: viewModel.selectedType!,
              );
            }
          } else {
            print(
                "ProductsScreen: Not fetching. Loading: ${viewModel.productisLoadingMore}, Has more: ${viewModel.producthasMoreData}");
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filterDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts(UserViewModel viewModel) async {
    print(
        "ProductsScreen: Pull-to-refresh triggered, selectedType: ${viewModel.selectedType}");
    viewModel.productList.clear();
    viewModel.productcurrentPage = 1;
    viewModel.producthasMoreData = true;
    viewModel.productisLoadingMore = false;
    if (viewModel.selectedType == null) {
      print("ProductsScreen: Refreshing all products (page 1)");
      await viewModel.getAllProducts(pageNumber: 1);
    } else {
      print(
          "ProductsScreen: Refreshing filtered products (type: ${viewModel.selectedType}, page 1)");
      await viewModel.getAllProductsWithFilters(
        pageNumber: 1,
        type: viewModel.selectedType!,
      );
    }
    print(
        "ProductsScreen: Refresh completed, productList length: ${viewModel.productList.length}, products: ${viewModel.productList.map((p) => "${p.name} (${p.productableType})").toList()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: appBarrWitoutAction(
        title: "Products",
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        leadingWidget: Container(),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          print(
              "ProductsScreen: Building UI - selectedType: ${viewModel.selectedType}, productList length: ${viewModel.productList.length}, isLoadingMore: ${viewModel.productisLoadingMore}");
          // Show full-screen loader during initial load
          if (viewModel.productList.isEmpty && viewModel.productisLoadingMore) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => _refreshProducts(viewModel),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Filter section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kText(text: "Filter by Type", fSize: 15.0),
                        UIHelper.verticalSpaceSm10,
                        DropDownTextField(
                          clearOption: true,
                          enableSearch: true,
                          textFieldDecoration:
                              customInputDecoration(hintText: "Select Type"),
                          dropDownList: const [
                            DropDownValueModel(name: "All", value: "all"),
                            DropDownValueModel(name: "Merchant", value: "m"),
                            DropDownValueModel(name: "Bank", value: "b"),
                          ],
                          onChanged: (value) {
                            _filterDebounce?.cancel();
                            _filterDebounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                if (value is DropDownValueModel && mounted) {
                                  final newType = value.value == "all"
                                      ? null
                                      : value.value as String?;
                                  if (newType != viewModel.selectedType) {
                                    print(
                                        "ProductsScreen: Filter changing from ${viewModel.selectedType} to $newType");
                                    viewModel.selectedType = newType;
                                    viewModel.productList.clear();
                                    viewModel.productcurrentPage = 1;
                                    viewModel.producthasMoreData = true;
                                    viewModel.productisLoadingMore = false;
                                    if (newType == null) {
                                      print(
                                          "ProductsScreen: Fetching all products (page 1)");
                                      viewModel.getAllProducts(pageNumber: 1);
                                    } else {
                                      print(
                                          "ProductsScreen: Fetching filtered products (type: $newType, page 1)");
                                      viewModel.getAllProductsWithFilters(
                                        pageNumber: 1,
                                        type: newType,
                                      );
                                    }
                                  } else {
                                    print(
                                        "ProductsScreen: No filter change needed (same type: $newType)");
                                  }
                                }
                              },
                            );
                          },
                        ),
                        UIHelper.verticalSpaceSm20,
                      ],
                    ),
                  ),
                ),
                // Products grid or empty state
                viewModel.productList.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.selectedType == null
                                    ? "No products found"
                                    : viewModel.selectedType == 'm'
                                        ? "No merchants found"
                                        : "No banks found",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: greyColor,
                                ),
                              ),
                              UIHelper.verticalSpaceSm10,
                              ElevatedButton(
                                onPressed: () => _refreshProducts(viewModel),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: whiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Show loading indicator at the end if more data is available
                              if (index == viewModel.productList.length &&
                                  viewModel.producthasMoreData) {
                                return viewModel.productisLoadingMore
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              Product product = viewModel.productList[index];
                              return gridWidget(product);
                            },
                            childCount: viewModel.productList.length +
                                (viewModel.producthasMoreData ? 1 : 0),
                          ),
                        ),
                      ),
                // End-of-list message
                if (!viewModel.producthasMoreData &&
                    viewModel.productList.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "No more products to load",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: greyColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget gridWidget(Product product) {
  final imageUrl = (product.image != null && product.image!.isNotEmpty)
      ? (product.image!.contains('http')
          ? product.image
          : "https://portal.buzdy.com/storage/admin/uploads/images/${product.image}")
      : null;
  print("ProductsScreen: Loading image for ${product.name}: $imageUrl");
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        ),
      );
    },
    child: Card(
      color: whiteColor,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 0.3, color: greyColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) {
                      print(
                          "Image load error for ${product.name}: $error");
                      return Image.asset(
                        "assets/images/placeholder.png",
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    "assets/images/placeholder.png",
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: kText(
                    text: product.name ?? "Unknown Product",
                    fWeight: fontWeightBold,
                    fSize: 12.0,
                    textalign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                UIHelper.verticalSpaceSm10,
                kText(
                  text: "Avg Rating: ${product.avgRating ?? 0}",
                  fWeight: fontWeightBold,
                  tColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  InputDecoration customInputDecoration({required String hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: greyColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: greyColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.blueAccent,
          width: 1.5,
        ),
      ),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 16.0,
      ),
    );
  }
}