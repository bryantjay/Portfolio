# Korean Bakery Market Basket Analysis

## Overview

This project performs a detailed Market Basket Analysis (MBA) on transaction data from a small Korean bakery. The analysis aims to uncover product associations and customer purchase patterns using various metrics, including support, confidence, lift, leverage, conviction, and Zhang's metric.

The dataset includes sales data for bakery products such as pastries, bread, cakes, and drinks, with the goal of identifying frequent itemsets and generating association rules to inform business strategies. The analysis also focuses on common item combinations and potential opportunities for product bundling, cross-selling, and upselling.

![sales_plot](https://github.com/bryantjay/Portfolio/blob/main/Korean%20Bakery%20Market%20Basket%20Analysis/plots/sales_plot.png?raw=true)

## Key Findings

- **Bread with Jam**: The strongest and most consistent rule observed is the pairing between "plain bread" and "jam." This rule stands out across **all** metrics—especially in confidence and conviction—suggesting a highly reliable customer pattern. If jam is purchased, there is a high likelihood that plain bread is purchased alongside it. Upselling jam to bread buyers could be a particularly effective strategy, and bundling both items as a combo could boost joint sales.

- **Item Bundles/Combos**: Frequent combinations of popular items like angbutter pastries, croissants, cakes, and drinks suggest clear opportunities for product bundling. For example, pairing angbutter with a coffee or tea could form a high-performing combo meal. Additionally, BOGO offers and cross-promotions between popular food categories could be used to drive multi-item purchases and reduce potential spoilage around scheduled weekly closures.

- **Pig in a Blanket?**: A recurring association between "wieners" and "croissants" emerged throughout the analysis. While the specific reason for this pattern is unknown, it could reflect customers recreating familiar items like pigs in a blanket or seeking a balanced savory-sweet combination. This finding suggests a potential product innovation or marketing opportunity worth further investigation.

- **Support vs. Confidence Insight**: A key insight from this project is that high confidence alone can be misleading. A rule’s confidence is often highly correlated with the consequent’s standalone support—meaning popular items like angbutter and croissants frequently appear as consequents in high-confidence rules, regardless of how meaningful the relationship is. This is visualized clearly in a scatterplot showing the near-linear relationship between confidence and consequent support. To mitigate this, additional metrics like lift or conviction are used to validate rules that may appear strong by confidence alone.

![confidence_consequent_association](https://github.com/bryantjay/Portfolio/blob/main/Korean%20Bakery%20Market%20Basket%20Analysis/plots/confidence_consequent_association.png?raw=true)

## Methodology

The project utilizes the **Apriori** algorithm from the `mlxtend` library to generate frequent itemsets, followed by the extraction of association rules. Various market basket metrics such as support, confidence, lift, leverage, conviction, and Zhang’s metric are used to evaluate and filter the rules.

The data is preprocessed through:
1. **One-Hot Encoding**: Product quantities are converted into binary values.
2. **Association Rules Generation**: Filtering by support thresholds and evaluating rule metrics to identify strong associations.
3. **Visualization**: Key metrics are visualized to reveal patterns and outliers in the data.

## Conclusion

The insights gained from this MBA help uncover how customers interact with different product categories, revealing valuable information about purchasing behavior. By identifying strong item pairings and high-potential bundle opportunities, bakery owners can better tailor their promotions, optimize inventory, and improve customer experience. This project demonstrates how Market Basket Analysis can offer actionable business intelligence, even for small-scale retail environments.

## Dependencies

- `mlxtend`
- `pandas`
- `matplotlib`
- `seaborn`

For more details on the methodology and findings, please refer to the project notebooks and code.
