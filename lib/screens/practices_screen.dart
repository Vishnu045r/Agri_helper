// lib/screens/practices_screen.dart
import 'package:flutter/material.dart';
import '../models/agricultural_practice.dart';
import '../utils/app_colors.dart';
import 'package:agri_helper/screens/menubar.dart'; // right-side menu drawer

class PracticesScreen extends StatelessWidget {
  PracticesScreen({Key? key}) : super(key: key);

  final List<AgriculturalPractice> practices = [
    AgriculturalPractice(
      category: 'Precision Farming',
      title: 'GPS-guided Farming',
      description: 'Use GPS technology for precise field operations.',
      benefits: [
        'Reduced input costs',
        'Higher yields',
        'Efficient resource use',
      ],
      implementation:
      'Survey fields and create accurate field maps. Install GPS guidance on tractors or use auto-steer kits. Calibrate equipment regularly, create controlled traffic lanes to reduce compaction, and plan variable-rate applications using prescription maps from soil tests or yield maps.',
      cost: '₹50,000 - ₹2,00,000',
      suitableFor: 'Large farms (>5 acres)',
    ),
    AgriculturalPractice(
      category: 'Sustainable Agriculture',
      title: 'Organic Farming',
      description: 'Chemical-free farming using natural inputs.',
      benefits: [
        'Premium prices',
        'Soil health improvement',
        'Environmental safety',
      ],
      implementation:
      'Start with soil testing and build soil organic matter via compost and green manures. Replace synthetic pesticides/fertilizers with biopesticides, biofertilizers, and crop rotations. Maintain documentation for input sources and harvesting to meet certification standards. Gradually transition fields (usually 2–3 years) and establish market channels for organic produce.',
      cost: '₹10,000 - ₹30,000 per acre',
      suitableFor: 'All farm sizes',
    ),
    AgriculturalPractice(
      category: 'Crop Management',
      title: 'Integrated Pest Management (IPM)',
      description: 'Eco-friendly pest control using multiple approaches.',
      benefits: [
        'Reduced pesticide use',
        'Cost savings',
        'Sustainable pest control',
      ],
      implementation:
      'Monitor pest levels regularly using traps and scouting; set economic thresholds. Encourage beneficial insects through habitat and flowering strips. Use cultural controls like crop rotation, resistant varieties and timely sowing. If chemical control is needed, choose targeted, low-risk options and apply spot treatments at recommended doses and timings.',
      cost: '₹5,000 - ₹15,000 per acre',
      suitableFor: 'All crops and farm sizes',
    ),
    AgriculturalPractice(
      category: 'Soil Health',
      title: 'Soil Testing & Management',
      description: 'Regular soil analysis for optimal nutrient management.',
      benefits: [
        'Improved yields',
        'Efficient fertilizer use',
        'Soil health monitoring',
      ],
      implementation:
      'Collect representative soil samples (0–15 cm) from grid or composite sampling. Send to a certified lab, interpret the report, and prepare a nutrient removal and replacement plan. Apply amendments (lime, gypsum) as recommended, adopt organic matter inputs (compost, manure), and use cover crops to reduce erosion and improve structure.',
      cost: '₹500 - ₹1,500 per sample',
      suitableFor: 'All farmers',
    ),
    AgriculturalPractice(
      category: 'Water Management',
      title: 'Drip Irrigation',
      description: 'Deliver water directly to plant roots for efficiency.',
      benefits: [
        'Water savings',
        'Better crop growth',
        'Reduced weed growth',
      ],
      implementation:
      'Conduct a field layout survey and design system with correct emitter spacing and flow rates. Install mainlines, submains, laterals, filters, pressure regulators, and fertigation unit if needed. Flush and maintain filters regularly, monitor emitter uniformity, and schedule irrigation based on crop stage and soil moisture sensors for best efficiency.',
      cost: '₹30,000 - ₹60,000 per acre (varies widely)',
      suitableFor: 'Horticulture & high-value crops',
    ),
    AgriculturalPractice(
      category: 'Agroforestry',
      title: 'Agroforestry Systems',
      description: 'Integrate trees with crops or livestock for diversified benefits.',
      benefits: [
        'Soil conservation',
        'Additional income streams',
        'Improved biodiversity',
      ],
      implementation:
      'Select tree species suited to local climate and cropping system. Plan spatial arrangements (boundary planting, alley cropping). Prepare planting pits, ensure initial watering and protection from grazing, prune periodically to reduce shading, and integrate nitrogen-fixing species where possible. Monitor interactions with crops for optimal spacing and yields.',
      cost: 'Variable — depends on species & scale',
      suitableFor: 'Medium to large farms, homesteads',
    ),
    AgriculturalPractice(
      category: 'Post-Harvest',
      title: 'Cold Storage & Grading',
      description: 'Preserve quality and extend shelf life of produce.',
      benefits: [
        'Reduced post-harvest loss',
        'Better market timing',
        'Higher prices',
      ],
      implementation:
      'Segregate and grade produce by size and quality at harvest. Clean and pre-cool produce before storage, then move to cold rooms maintained at crop-specific temperatures and humidity. Use proper packaging and ventilation in cold stores; track inventory with FIFO; train workers on hygiene and handling to minimize bruising and contamination.',
      cost: '₹1,00,000+ (depends on capacity)',
      suitableFor: 'Fruit & vegetable producers, aggregators',
    ),
    // small-additional examples
    AgriculturalPractice(
      category: 'Fertilizer Management',
      title: 'Balanced Fertilization',
      description: 'Apply nutrients based on crop need and soil tests.',
      benefits: [
        'Higher nutrient-use efficiency',
        'Reduced input waste',
        'Improved crop yields',
      ],
      implementation:
      'Use soil and leaf tests to determine nutrient status. Prepare a field-specific nutrient plan including macro- and micro-nutrients. Time applications to crop uptake (split doses), consider use of coated/slow-release fertilizers or fertigation for precision, and combine with organic sources to maintain soil health.',
      cost: 'Variable',
      suitableFor: 'All farmers',
    ),
    AgriculturalPractice(
      category: 'Mechanization',
      title: 'Small-scale Mechanization',
      description: 'Use appropriate machines to reduce labor and increase timeliness.',
      benefits: [
        'Lower labor costs',
        'Increased timeliness of operations',
        'Improved efficiency',
      ],
      implementation:
      'Assess farm operations to prioritize implements (rotavator, seeders, mini-tillers). Choose affordable, fuel-efficient machines or custom hiring options. Train operators on maintenance and safe operation, schedule regular servicing, and store equipment under shelter to extend life.',
      cost: '₹20,000 - ₹2,00,000 (depending on machine)',
      suitableFor: 'Small to medium farms',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ⭐ RIGHT SIDE MENUBAR
      endDrawer: AppMenuDrawer(
        onNavigate: (dest) {
          Navigator.pop(context);

          switch (dest) {
            case MenuDestination.home:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case MenuDestination.schemes:
              Navigator.pushNamed(context, '/schemes');
              break;
            case MenuDestination.practices:
              break; // already here
            case MenuDestination.expertHelp:
              Navigator.pushNamed(context, '/expert_help');
              break;
            case MenuDestination.market:
              Navigator.pushNamed(context, '/market');
              break;
            case MenuDestination.profile:
              Navigator.pushNamed(context, '/profile');
              break;
            case MenuDestination.logout:
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
      ),

      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Farming Practices'),

        // ⭐ BACK ARROW (go to Home always)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),

        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              tooltip: 'Open menu',
            ),
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: practices.length,
        itemBuilder: (context, index) {
          final practice = practices[index];

          return InkWell(
            onTap: () => _showPracticeDetails(context, practice),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14), // normal padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      practice.title,
                      style: TextStyle(
                        fontSize: 18, // normal readable size
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Category
                    Text(
                      practice.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      practice.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Cost & Suitable For (smaller row)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Cost: ${practice.cost}',
                            style: TextStyle(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Suitable: ${practice.suitableFor}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPracticeDetails(BuildContext context, AgriculturalPractice practice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.55,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  practice.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  practice.category,
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      _detailSection('Description', practice.description),
                      _detailSection('Implementation', practice.implementation),
                      _detailSection('Cost', practice.cost),
                      _detailSection('Suitable For', practice.suitableFor),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Benefits',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            ...practice.benefits.map(
                                  (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 18, color: AppColors.primaryGreen),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        b,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                            height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Close',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _detailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style:
            TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
