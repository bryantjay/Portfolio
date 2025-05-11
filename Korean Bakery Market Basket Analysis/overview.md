# Korean Bakery Market Basket Analysis

## Overview

This project performs a detailed Market Basket Analysis (MBA) on transaction data from a small Korean bakery. The analysis aims to uncover product associations and customer purchase patterns using various metrics, including support, confidence, lift, leverage, conviction, and Zhang's metric.

The dataset includes sales data for bakery products such as pastries, bread, cakes, and drinks, with the goal of identifying frequent itemsets and generating association rules to inform business strategies. The analysis also focuses on common item combinations and potential opportunities for product bundling, cross-selling, and upselling.

## Key Findings

- **Bread with Jam**: The combination of "plain bread" and "jam" shows significant association across multiple metrics, suggesting a strong and intuitive pairing. Upselling jam to bread buyers could be an effective marketing strategy.
  
- **Item Bundles/Combos**: Popular items like angbutter pastries, croissants, and cakes often appear together. Marketing campaigns could leverage these common pairings through BOGO bundling or food-and-drink combos to boost sales.

- **Pig in a Blanket**: The "wiener" and "croissant" pairing emerged as an interesting association, warranting further investigation. This could lead to a new top-selling item or an enhanced version of an existing one.

## Methodology

The project utilizes the **Apriori** algorithm from the `mlxtend` library to generate frequent itemsets, followed by the extraction of association rules. Various market basket metrics such as support, confidence, lift, leverage, conviction, and Zhang’s metric are used to evaluate and filter the rules.

The data is preprocessed through:
1. **One-Hot Encoding**: Product quantities are converted into binary values.
2. **Association Rules Generation**: Filtering by support thresholds and evaluating rule metrics to identify strong associations.
3. **Visualization**: Key metrics are visualized to reveal patterns and outliers in the data.

## Conclusion

The insights gained from this MBA can help bakery owners and managers optimize their product offerings, design effective promotions, and understand customer preferences. The project demonstrates how Market Basket Analysis can be applied to small retail datasets for actionable business intelligence.

## Dependencies

- `mlxtend`
- `pandas`
- `matplotlib`
- `seaborn`

For more details on the methodology and findings, please refer to the project notebooks and code.
