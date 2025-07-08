import "package:example/models/product.dart";
import "package:example/services/product_service.dart";
import "package:flutter/material.dart";
import "package:local_query_filter/local_query_filter.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  bool onlyActive = false;
  bool under100 = false;
  bool inStockOnly = false;
  bool recentOnly = false;

  String? selectedCategory;
  String selectedSortField = "price";
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    _allProducts = ProductService.getMockProducts();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    final List<QueryConstraint<Product>> constraints = [];

    if (onlyActive) {
      constraints.add(
        BooleanConstraint.isTrue(fieldExtractor: (p) => p.isActive),
      );
    }

    if (under100) {
      constraints.add(
        ComparisonConstraint.lessThan(
          value: 100,
          fieldExtractor: (p) => p.price,
        ),
      );
    }

    if (inStockOnly) {
      constraints.add(
        ComparisonConstraint.greaterThan(
          value: 0,
          fieldExtractor: (p) => p.stock,
        ),
      );
    }

    if (recentOnly) {
      constraints.add(
        DateRangeConstraint.forRange(
          dateRange: DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
          fieldExtractor: (p) => p.createdAt,
        ),
      );
    }

    if (selectedCategory != null) {
      constraints.add(
        ComparisonConstraint.equal(
          value: selectedCategory!,
          fieldExtractor: (p) => p.category,
        ),
      );
    }

    Comparable Function(Product)? sortExtractor;
    switch (selectedSortField) {
      case "price":
        sortExtractor = (p) => p.price;
      case "name":
        sortExtractor = (p) => p.name;
      case "createdAt":
        sortExtractor = (p) => p.createdAt;
    }

    final filter = QueryFilter<Product>(
      constraints: constraints,
      searchTerm: _searchController.text.trim(),
      searchFieldsExtractor: (p) => [
        p.name,
        p.description,
        p.category,
        ...p.tags,
      ],
      sortingFieldExtractor: sortExtractor,
      ascending: sortAscending,
    );

    try {
      final results = await filter.applyFilterAndSort(_allProducts);
      setState(() => _filteredProducts = results);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final allCategories = _allProducts.map((p) => p.category).toSet().toList();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 80,
              title: SearchBar(
                controller: _searchController,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.surfaceContainer,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                trailing: [
                  ValueListenableBuilder(
                    valueListenable: _searchController,
                    builder: (context, value, _) {
                      final search = value.text.trim();
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: search.isEmpty
                            ? null
                            : () {
                                _searchController.clear();
                                _applyFilters();
                              },
                      );
                    },
                  ),
                ],
                onChanged: (_) => _applyFilters(),
              ),
            ),

            SliverToBoxAdapter(
              child: Card.outlined(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  shape: LinearBorder.none,
                  title: const Text("Filter"),
                  collapsedShape: LinearBorder.none,
                  leading: const Icon(Icons.filter_list),
                  childrenPadding: const EdgeInsets.all(16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          selected: onlyActive,
                          label: const Text("Only Active"),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (val) {
                            setState(() => onlyActive = val);
                            _applyFilters();
                          },
                        ),
                        ChoiceChip(
                          selected: under100,
                          label: const Text("Price < ₹100"),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (val) {
                            setState(() => under100 = val);
                            _applyFilters();
                          },
                        ),
                        ChoiceChip(
                          selected: inStockOnly,
                          label: const Text("In Stock Only"),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (val) {
                            setState(() => inStockOnly = val);
                            _applyFilters();
                          },
                        ),
                        ChoiceChip(
                          selected: recentOnly,
                          label: const Text("Created in Last 30 Days"),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onSelected: (val) {
                            setState(() => recentOnly = val);
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Category"),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ChoiceChip(
                              selected: selectedCategory == null,
                              label: const Text("All"),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onSelected: (val) {
                                setState(() => selectedCategory = null);
                                _applyFilters();
                              },
                            ),
                            ...allCategories.map(
                              (cat) => ChoiceChip(
                                selected: selectedCategory == cat,
                                label: Text(cat),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onSelected: (val) {
                                  setState(() => selectedCategory = cat);
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Card.outlined(
                margin: const EdgeInsets.all(12),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  shape: LinearBorder.none,
                  title: const Text("Sort"),
                  leading: const Icon(Icons.sort),
                  collapsedShape: LinearBorder.none,
                  childrenPadding: const EdgeInsets.all(16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Sort By"),
                      subtitle: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text("Price"),
                            selected: selectedSortField == "price",
                            onSelected: (_) {
                              setState(() => selectedSortField = "price");
                              _applyFilters();
                            },
                          ),
                          ChoiceChip(
                            label: const Text("Name"),
                            selected: selectedSortField == "name",
                            onSelected: (_) {
                              setState(() => selectedSortField = "name");
                              _applyFilters();
                            },
                          ),
                          ChoiceChip(
                            label: const Text("Created At"),
                            selected: selectedSortField == "createdAt",
                            onSelected: (_) {
                              setState(() => selectedSortField = "createdAt");
                              _applyFilters();
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Sort Order"),
                      subtitle: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            selected: sortAscending,
                            label: const Text("Ascending"),
                            onSelected: (_) {
                              setState(() => sortAscending = true);
                              _applyFilters();
                            },
                          ),
                          ChoiceChip(
                            selected: !sortAscending,
                            label: const Text("Descending"),
                            onSelected: (_) {
                              setState(() => sortAscending = false);
                              _applyFilters();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: Divider()),

            SliverToBoxAdapter(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: _isLoading ? 4 : 0,
                  child: const LinearProgressIndicator(),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: _filteredProducts.length,
                (context, index) {
                  final product = _filteredProducts[index];
                  return Card.filled(
                    color: colorScheme.secondaryContainer,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text("Price: ₹${product.price.toStringAsFixed(2)}"),
                          Text("Stock: ${product.stock}"),
                          Text("Category: ${product.category}"),
                          Text('Active: ${product.isActive ? 'Yes' : 'No'}'),
                          Text('Tags: ${product.tags.join(', ')}'),
                          Text(
                            "Created: ${product.createdAt.toLocal().toIso8601String().substring(0, 10)}",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Center(
          child: Text(
            "${_filteredProducts.length} products found",
            style: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.normal,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
