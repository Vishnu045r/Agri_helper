// lib/screens/schemes_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/government_scheme.dart';
import '../widgets/scheme_card.dart';
import '../utils/app_colors.dart';
import 'package:agri_helper/screens/menubar.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Financial Support',
    'Insurance',
    'Credit',
    'Infrastructure',
    'Market Access',
  ];

  final List<GovernmentScheme> _schemes = [
    GovernmentScheme(
      name: 'PM-KISAN',
      fullName: 'Pradhan Mantri Kisan Samman Nidhi',
      description: 'Direct income support to small and marginal farmers.',
      benefits: '₹6,000 per year in three installments.',
      eligibility: 'Farmers with up to 2 hectares of landholding (see official exclusions).',
      applicationProcess: 'Online registration through PM-KISAN portal (eKYC required).',
      documentsRequired: [
        'Aadhaar card',
        'Bank account details',
        'Land ownership documents',
      ],
      category: 'Financial Support',
      website: 'https://pmkisan.gov.in/',
    ),
    GovernmentScheme(
      name: 'PMFBY',
      fullName: 'Pradhan Mantri Fasal Bima Yojana',
      description: 'Insurance for crops damaged by natural calamities.',
      benefits: 'Low premium: 2% (Kharif), 1.5% (Rabi) for notified crops/areas.',
      eligibility: 'Farmers growing notified crops in notified areas/seasons.',
      applicationProcess: 'Enroll through banks or insurance companies during enrollment window.',
      documentsRequired: ['Farmer ID', 'Land records', 'Bank account details'],
      category: 'Insurance',
      website: 'https://pmfby.gov.in/',
    ),
    GovernmentScheme(
      name: 'KCC',
      fullName: 'Kisan Credit Card Scheme',
      description: 'Short-term crop loan support.',
      benefits: 'Credit limit for cultivation, post-harvest and allied activities.',
      eligibility: 'Owner-cultivators, tenant farmers, oral lessees, sharecroppers (bank rules apply).',
      applicationProcess: 'Apply via banks with required documentation.',
      documentsRequired: ['Land documents', 'Identity proof', 'Bank statement'],
      category: 'Credit',
      // changed as requested: use PM-KISAN link for applying KCC
      website: 'https://pmkisan.gov.in/',
    ),
    GovernmentScheme(
      name: 'Soil Health Card',
      fullName: 'Soil Health Card Scheme',
      description: 'Soil nutrient testing and recommendations.',
      benefits: 'Better crop yields & soil management (lab test & nutrient suggestions).',
      eligibility: 'Open to all farmers (state-level implementation).',
      applicationProcess: 'Apply at local agriculture office or via state portal.',
      documentsRequired: ['Aadhaar card', 'Land papers'],
      category: 'Infrastructure',
      website: 'https://soilhealth.dac.gov.in',
    ),
    GovernmentScheme(
      name: 'eNAM',
      fullName: 'National Agriculture Market',
      description: 'Online trading platform for farm produce.',
      benefits: 'Better markets & price discovery.',
      eligibility: 'Farmers/traders who register on eNAM and comply with mandi registration rules.',
      applicationProcess: 'Register on eNAM portal (select APMC / mandi).',
      documentsRequired: ['Farmer ID', 'Trader license'],
      category: 'Market Access',
      website: 'https://enam.gov.in',
    ),
    GovernmentScheme(
      name: 'RKVY',
      fullName: 'Rashtriya Krishi Vikas Yojana',
      description: 'Agriculture development funding for state projects.',
      benefits: 'Supports agricultural infrastructure and state projects.',
      eligibility: 'Primarily state agriculture departments; benefits flow via projects.',
      applicationProcess: 'Implemented by state departments (contact local agri office).',
      documentsRequired: [],
      category: 'Infrastructure',
      website: 'https://rkvy.da.gov.in',
    ),
  ];

  List<GovernmentScheme> get _filteredSchemes {
    if (_selectedCategory == 'All') return _schemes;
    return _schemes.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// RIGHT-SIDE MENUBAR
      endDrawer: AppMenuDrawer(
        onNavigate: (dest) {
          Navigator.pop(context);

          switch (dest) {
            case MenuDestination.home:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case MenuDestination.schemes:
              break; // already here
            case MenuDestination.practices:
              Navigator.pushNamed(context, '/practices');
              break;
            case MenuDestination.market:
              Navigator.pushNamed(context, '/market');
              break;
            case MenuDestination.expertHelp:
              Navigator.pushNamed(context, '/expert_help');
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
        title: const Text('Government Schemes'),
        foregroundColor: Colors.white,

        /// BACK ARROW
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // Go to home
          },
        ),

        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // CATEGORY FILTER LIST
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppColors.primaryGreen.withOpacity(0.25),
                    checkmarkColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
          ),

          // SCHEMES LIST
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSchemes.length,
              itemBuilder: (_, i) {
                return SchemeCard(
                  scheme: _filteredSchemes[i],
                  onTap: () => _showSchemeDetails(_filteredSchemes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // SCHEME DETAILS BOTTOM SHEET
  // ------------------------------------------------------------------
  void _showSchemeDetails(GovernmentScheme scheme) {
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // title
                Text(
                  scheme.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),

                Text(
                  scheme.fullName,
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 10),

                // website link (tap opens site)
                InkWell(
                  onTap: () => _launchWebsite(scheme.website),
                  child: Text(
                    scheme.website,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      _detailSection('Description', scheme.description),
                      _detailSection('Benefits', scheme.benefits),
                      _detailSection('Eligibility', scheme.eligibility),
                      _detailSection('Application Process', scheme.applicationProcess),
                      _documentsSection(scheme.documentsRequired),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // New: Check Eligibility button (opens small form)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showEligibilityForm(scheme);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Check Eligibility', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply Now opens site directly
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _launchWebsite(scheme.website),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Apply Now',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Small eligibility form dialog
  void _showEligibilityForm(GovernmentScheme scheme) {
    final _landController = TextEditingController();
    final _cropsController = TextEditingController();
    bool _isTenant = false;
    bool _isRegisteredEnam = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Check Eligibility for ${scheme.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // landholding
                  TextField(
                    controller: _landController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Landholding (hectares)', hintText: 'e.g. 1.25'),
                  ),
                  const SizedBox(height: 8),

                  // crops
                  TextField(
                    controller: _cropsController,
                    decoration: const InputDecoration(labelText: 'Crops (comma separated)', hintText: 'e.g. onion, potato'),
                  ),
                  const SizedBox(height: 8),

                  // tenant
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tenant farmer?'),
                    value: _isTenant,
                    onChanged: (v) => setState(() => _isTenant = v),
                  ),

                  // eNAM registered
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Registered on eNAM?'),
                    value: _isRegisteredEnam,
                    onChanged: (v) => setState(() => _isRegisteredEnam = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                onPressed: () {
                  final land = double.tryParse(_landController.text.trim()) ?? 0.0;
                  final cropsRaw = _cropsController.text.trim();
                  final crops = cropsRaw.isNotEmpty ? cropsRaw.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty).toList() : <String>[];

                  final result = _evaluateEligibilityForScheme(scheme, land, _isTenant, crops, _isRegisteredEnam);
                  Navigator.pop(ctx); // close form
                  _showEligibilityResultDialog(scheme, result);
                },
                child: const Text('Check'),
              ),
            ],
          );
        });
      },
    );
  }

  // A slightly stronger (officially-sourced) eligibility evaluator
  // Uses primary conditions from official scheme pages. For full legal checks, the official site/local office should be consulted.
  _EligibilityResult _evaluateEligibilityForScheme(
      GovernmentScheme scheme,
      double landHectares,
      bool isTenant,
      List<String> crops,
      bool isEnamRegistered) {
    final name = scheme.name.toLowerCase();

    // PM-KISAN: primary criteria is landholding and exclusions apply (see portal).
    if (name == 'pm-kisan' || name.contains('pm-kisan')) {
      if (landHectares > 0 && landHectares <= 2.0) {
        return _EligibilityResult(
          true,
          'Primary check passed: Landholding ${landHectares.toStringAsFixed(2)} ha ≤ 2 ha. You appear to meet the main PM-KISAN criterion. Note: official exclusions and eKYC/Aadhaar verification still apply — confirm on the PM-KISAN portal.',
        );
      } else if (landHectares == 0) {
        return _EligibilityResult(false,
            'No landholding entered — PM-KISAN is intended for cultivable landholders. See the official PM-KISAN portal for full criteria and exclusions.');
      } else {
        return _EligibilityResult(false,
            'Landholding ${landHectares.toStringAsFixed(2)} ha > 2 ha — you do not meet the primary PM-KISAN landholding criterion. Check the official site for exceptions or state rules.');
      }
    }

    // PMFBY: crop insurance only for notified crops in notified areas & seasons.
    if (name.contains('pmfby') || name.contains('pm-fby') || name.contains('pmf by')) {
      if (crops.isNotEmpty) {
        return _EligibilityResult(true,
            'Crops entered: ${crops.join(', ')}. Farmers growing notified crops in notified areas/seasons can enroll in PMFBY. Please verify coverage for your crop/area/season with the PMFBY portal or your bank/insurer.');
      } else {
        return _EligibilityResult(false,
            'No crop entered — PMFBY covers notified crops. Enter your crop(s) and verify on the PMFBY portal or with your bank/insurer.');
      }
    }

    // KCC: owner-cultivators, tenant farmers, sharecroppers are generally eligible.
    if (name == 'kcc' || name.contains('kisan credit') || name.contains('kcc')) {
      if (landHectares > 0 || isTenant) {
        return _EligibilityResult(true,
            'KCC primary criteria met (owner cultivator or tenant/sharecropper). You can apply via the PM-KISAN portal or your bank — prepare identity, land/tenant documents and bank KYC.');
      } else {
        return _EligibilityResult(false,
            'KCC typically requires farm activity (owner cultivator, tenant, sharecropper). Visit your bank or PM-KISAN portal for application guidance and to check alternate pathways.');
      }
    }

    // Soil Health Card: broadly available to farmers
    if (name.contains('soil health') || name.contains('soilhealth')) {
      return _EligibilityResult(true,
          'Soil Health Card is available to farmers for soil testing and nutrient recommendations. Register via your state portal or local agriculture office.');
    }

    // eNAM: registration required for trading
    if (name.contains('enam') || name.contains('national agriculture market')) {
      if (isEnamRegistered) {
        return _EligibilityResult(true, 'You indicated you are registered on eNAM — you can trade on the platform (follow mandi/APMC rules).');
      } else {
        return _EligibilityResult(false, 'eNAM requires registration. Register on the official eNAM portal to participate in the market.');
      }
    }

    // RKVY: state-level projects/funding — generally not direct individual transfers
    if (name.contains('rkvy') || name.contains('rashtriya krishi')) {
      return _EligibilityResult(false,
          'RKVY funds are routed via state agriculture departments and project schemes. Contact your state agriculture office to learn about RKVY projects and how farmers can benefit.');
    }

    // Default conservative fallback
    if (landHectares > 0 || isTenant) {
      return _EligibilityResult(true,
          'Based on provided info (landholding or tenant status) you appear to be an active farmer and may be eligible. Confirm details on the official scheme page or with your local agriculture office.');
    }

    return _EligibilityResult(false,
        'Unable to determine eligibility from the provided information. Please consult the official scheme page or contact your local agriculture office for confirmation.');
  }

  // Show eligibility result in dialog and allow opening website accordingly
  void _showEligibilityResultDialog(GovernmentScheme scheme, _EligibilityResult result) {
    final bool eligible = result.eligible;
    final String title = eligible ? '✔ You are eligible' : '✖ You are not eligible';
    final String footerNote =
        'This check uses primary public eligibility criteria. Some schemes have additional exclusions, state-level variations, or document verifications. Always verify on the official site.';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Reason / main message
                  Text(
                    result.reason,
                    style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
                  ),

                  const SizedBox(height: 18),

                  // Actions row (mirrors old AlertDialog buttons)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('OK'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx); // close dialog
                            _launchWebsite(scheme.website);
                          },
                          child: Text(eligible ? 'Proceed to Apply' : 'Learn more & next steps'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Footer disclaimer note (small grey text shown below actions)
                  Text(
                    footerNote,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  void _showApplicationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Application Submitted'),
        content: const Text('Your application has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _documentsSection(List<String> docs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Documents',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          ...docs.map(
                (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Local helper class for results
class _EligibilityResult {
  final bool eligible;
  final String reason;
  _EligibilityResult(this.eligible, this.reason);
}
