import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});
  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _radarCtrl;
  String _selectedType = 'ALS';
  bool _isRequesting = false;
  bool _requested = false;
  bool _bookingForOther = false;
  bool _isLoadingFamilyMembers = false;
  String? _familyMembersError;
  List<_AmbulanceFamilyMember> _familyMembers = [];
  _AmbulanceFamilyMember? _selectedFamilyMember;
  Map<String, dynamic>? _ambulanceRequest;
  final _pickupAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pulseCtrl.dispose();
    _radarCtrl.dispose();
    _pickupAddressController.dispose();
    _destinationAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    setState(() {
      _isLoadingFamilyMembers = true;
      _familyMembersError = null;
    });
    try {
      final response = await ApiService.getFamilyMembers();
      final members = response
          .whereType<Map>()
          .map(
            (member) => _AmbulanceFamilyMember.fromJson(
              Map<String, dynamic>.from(member),
            ),
          )
          .whereType<_AmbulanceFamilyMember>()
          .toList();
      if (!mounted) return;
      setState(() {
        _familyMembers = members;
        final selectedUserId = _selectedFamilyMember?.userId;
        _selectedFamilyMember = null;
        for (final member in members) {
          if (member.userId == selectedUserId) {
            _selectedFamilyMember = member;
            break;
          }
        }
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _familyMembersError = error.message);
    } on FormatException catch (error) {
      if (mounted) setState(() => _familyMembersError = error.message);
    } on Exception catch (error) {
      if (mounted) setState(() => _familyMembersError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingFamilyMembers = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _requestAmbulance() async {
    if (_bookingForOther) {
      final member = _selectedFamilyMember;
      final pickupAddress = _pickupAddressController.text.trim();
      final destinationAddress = _destinationAddressController.text.trim();
      if (member == null) {
        _showMessage('Select a connected family member.');
        return;
      }
      if (pickupAddress.length < 5 || destinationAddress.length < 5) {
        _showMessage('Enter the member’s pickup and destination addresses.');
        return;
      }

      setState(() => _isRequesting = true);
      try {
        final request = await ApiService.createAmbulanceRequest({
          'patient_user_id': member.userId,
          'pickup_address': pickupAddress,
          'destination_address': destinationAddress,
          'patient_name': member.name,
          'ambulance_type': _selectedType == 'ALS' ? 'advanced' : 'basic',
        });
        if (!mounted) return;
        setState(() {
          _ambulanceRequest = request;
          _requested = true;
        });
      } on ApiException catch (error) {
        if (mounted) _showMessage(error.message);
      } on FormatException catch (error) {
        if (mounted) _showMessage(error.message);
      } on Exception catch (error) {
        if (mounted) _showMessage('Could not request an ambulance: $error');
      } finally {
        if (mounted) setState(() => _isRequesting = false);
      }
      return;
    }

    setState(() => _isRequesting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isRequesting = false;
        _ambulanceRequest = null;
        _requested = true;
      });
    }
  }

  Future<void> _cancelRequest() async {
    if (_bookingForOther) {
      final requestData = _ambulanceRequest?['request'] is Map
          ? Map<String, dynamic>.from(_ambulanceRequest!['request'] as Map)
          : _ambulanceRequest;
      final requestId = requestData?['request_id'] ?? requestData?['id'];
      final parsedRequestId = requestId is int
          ? requestId
          : int.tryParse(requestId?.toString() ?? '');
      if (parsedRequestId == null) {
        _showMessage('The server did not return an ID for this request.');
        return;
      }
      try {
        await ApiService.cancelAmbulanceRequest(parsedRequestId);
      } on ApiException catch (error) {
        if (mounted) _showMessage(error.message);
        return;
      } on FormatException catch (error) {
        if (mounted) _showMessage(error.message);
        return;
      } on Exception catch (error) {
        if (mounted) _showMessage('Could not cancel the request: $error');
        return;
      }
    }
    if (mounted) {
      setState(() {
        _requested = false;
        _ambulanceRequest = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textMid,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Emergency Ambulance',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency header
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB71C1C),
                      Color(0xFFD32F2F),
                      Color(0xFFE53935),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Radar animation
                    Positioned(
                      right: -20,
                      top: -20,
                      child: AnimatedBuilder(
                        animation: _radarCtrl,
                        builder: (_, __) => Opacity(
                          opacity: 0.15,
                          child: Transform.rotate(
                            angle: _radarCtrl.value * 2 * math.pi,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, child) => Transform.scale(
                                scale: 0.95 + _pulseCtrl.value * 0.08,
                                child: child,
                              ),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🚑',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emergency Ambulance',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'ALS/BLS fleet available 24/7',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PulsingDot(color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Average response time: 8 minutes',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (_requested) ...[
                _TrackingCard(
                  radarCtrl: _radarCtrl,
                  patientName: _bookingForOther
                      ? _selectedFamilyMember?.name
                      : null,
                  pickupAddress: _bookingForOther
                      ? _pickupAddressController.text.trim()
                      : null,
                  request: _ambulanceRequest,
                  onCancel: _cancelRequest,
                ),
              ] else ...[
                // Ambulance type selector
                Text(
                  'Select Ambulance Type',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _TypeCard(
                        type: 'ALS',
                        label: 'Advanced Life Support',
                        desc:
                            'ICU on wheels — ventilator, monitor, defibrillator',
                        icon: '🏥',
                        isSelected: _selectedType == 'ALS',
                        onTap: () => setState(() => _selectedType = 'ALS'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _TypeCard(
                        type: 'BLS',
                        label: 'Basic Life Support',
                        desc:
                            'First aid kit, oxygen, stretcher, basic equipment',
                        icon: '🚑',
                        isSelected: _selectedType == 'BLS',
                        onTap: () => setState(() => _selectedType = 'BLS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Quick Request
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request Ambulance',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We\'ll dispatch the nearest $_selectedType ambulance to your location',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Who needs the ambulance?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _BookingTargetOption(
                              label: 'For me',
                              icon: Icons.person_outline_rounded,
                              selected: !_bookingForOther,
                              onTap: () =>
                                  setState(() => _bookingForOther = false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _BookingTargetOption(
                              label: 'For family member',
                              icon: Icons.people_outline_rounded,
                              selected: _bookingForOther,
                              onTap: () {
                                setState(() => _bookingForOther = true);
                                if (!_isLoadingFamilyMembers &&
                                    _familyMembers.isEmpty &&
                                    _familyMembersError == null) {
                                  _loadFamilyMembers();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_bookingForOther) ...[
                        const SizedBox(height: 14),
                        if (_isLoadingFamilyMembers)
                          const LinearProgressIndicator()
                        else if (_familyMembersError != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Could not load family members: $_familyMembersError',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _loadFamilyMembers,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again'),
                              ),
                            ],
                          )
                        else if (_familyMembers.isEmpty)
                          Text(
                            'No connected family members are available. Add or accept a family connection first.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSoft,
                            ),
                          )
                        else ...[
                          DropdownButtonFormField<int>(
                            initialValue: _selectedFamilyMember?.userId,
                            decoration: const InputDecoration(
                              labelText: 'Connected family member',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            items: _familyMembers
                                .map(
                                  (member) => DropdownMenuItem(
                                    value: member.userId,
                                    child: Text(
                                      '${member.name} · ${member.relation}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (userId) => setState(() {
                              _selectedFamilyMember = userId == null
                                  ? null
                                  : _familyMembers.firstWhere(
                                      (member) => member.userId == userId,
                                    );
                            }),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _pickupAddressController,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Family member’s pickup address',
                              hintText: 'Enter where the member is waiting',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _destinationAddressController,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Destination address',
                              hintText: 'Enter the hospital or destination',
                              prefixIcon: Icon(Icons.local_hospital_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _bookingForOther
                                  ? Icons.location_on_outlined
                                  : Icons.my_location_rounded,
                              size: 20,
                              color: AppColors.blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _bookingForOther
                                        ? 'Pickup location'
                                        : 'Current Location',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    _bookingForOther
                                        ? 'Use the family member’s address entered above'
                                        : 'Detecting your location…',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: AppColors.textSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_bookingForOther)
                              const Icon(
                                Icons.edit_location_outlined,
                                size: 18,
                                color: AppColors.textSoft,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _isRequesting ? null : _requestAmbulance,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isRequesting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.emergency_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Request $_selectedType Ambulance Now',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          '📞 Or call 108 for immediate help',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbulanceFamilyMember {
  final int userId;
  final String name;
  final String relation;

  const _AmbulanceFamilyMember({
    required this.userId,
    required this.name,
    required this.relation,
  });

  static _AmbulanceFamilyMember? fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    final member = json['member'] is Map
        ? Map<String, dynamic>.from(json['member'] as Map)
        : <String, dynamic>{};
    final userIdValue =
        json['user_id'] ??
        json['member_user_id'] ??
        user['id'] ??
        member['user_id'];
    final userId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? '');
    final name =
        _firstString([
          json['name'],
          json['full_name'],
          json['member_name'],
          user['name'],
          user['full_name'],
          member['name'],
          member['full_name'],
        ]) ??
        _joinedName(
          json['first_name'] ?? user['first_name'] ?? member['first_name'],
          json['last_name'] ?? user['last_name'] ?? member['last_name'],
        );
    if (userId == null || name == null) return null;
    return _AmbulanceFamilyMember(
      userId: userId,
      name: name,
      relation:
          _firstString([
            json['relationship'],
            json['relation'],
            member['relationship'],
            member['relation'],
          ]) ??
          'Family member',
    );
  }

  static String? _firstString(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static String? _joinedName(dynamic firstName, dynamic lastName) {
    final name = [
      if (firstName is String) firstName.trim(),
      if (lastName is String) lastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    return name.isEmpty ? null : name;
  }
}

class _BookingTargetOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BookingTargetOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.blue : AppColors.textSoft,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.blue : AppColors.textMid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final String type, label, desc, icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeCard({
    required this.type,
    required this.label,
    required this.desc,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.accent.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accent
                  : _hovered
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.icon, style: const TextStyle(fontSize: 28)),
                  const Spacer(),
                  if (widget.isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.type,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMid,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSoft,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final AnimationController radarCtrl;
  final VoidCallback onCancel;
  final String? patientName;
  final String? pickupAddress;
  final Map<String, dynamic>? request;

  const _TrackingCard({
    required this.radarCtrl,
    required this.onCancel,
    this.patientName,
    this.pickupAddress,
    this.request,
  });

  @override
  Widget build(BuildContext context) {
    final requestData = request?['request'] is Map
        ? Map<String, dynamic>.from(request!['request'] as Map)
        : request ?? <String, dynamic>{};
    final status = requestData['status']?.toString();
    final isFamilyBooking = patientName != null;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Radar
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(
                  3,
                  (i) => AnimatedBuilder(
                    animation: radarCtrl,
                    builder: (_, __) {
                      final v = (radarCtrl.value + i / 3) % 1;
                      return Container(
                        width: 60 + v * 80,
                        height: 60 + v * 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent.withValues(
                              alpha: 0.3 * (1 - v),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.1),
                  ),
                  child: const Center(
                    child: Text('🚑', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isFamilyBooking
                ? 'Ambulance requested for $patientName'
                : 'Ambulance on the Way!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          if (isFamilyBooking) ...[
            Text(
              status == null || status.isEmpty
                  ? 'Request submitted · waiting for dispatch updates'
                  : 'Dispatch status: $status',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pickup: $pickupAddress',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
            ),
            const SizedBox(height: 6),
            Text(
              'Location is based on the pickup address provided; live GPS sharing is not available.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSoft,
              ),
            ),
          ] else ...[
            Text(
              'ETA: 8 minutes',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Driver: Rajesh Kumar · KA-01-AB-1234',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (!isFamilyBooking)
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.blue, AppColors.blueMid],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Call Driver',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!isFamilyBooking) const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isFamilyBooking ? 'Cancel Request' : 'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMid,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 1, end: 0.3).animate(_ctrl),
    child: Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    ),
  );
}
