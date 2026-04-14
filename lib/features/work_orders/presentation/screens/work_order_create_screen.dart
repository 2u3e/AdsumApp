import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/work_enums.dart';

/// Yeni is emri olusturma ekrani
/// Is turune bagli dinamik alanlar iceriyor
class WorkOrderCreateScreen extends ConsumerStatefulWidget {
  const WorkOrderCreateScreen({super.key});

  @override
  ConsumerState<WorkOrderCreateScreen> createState() => _WorkOrderCreateScreenState();
}

class _WorkOrderCreateScreenState extends ConsumerState<WorkOrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWorkType;
  WorkPriority _priority = WorkPriority.normal;

  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _applicantNameController = TextEditingController();
  final _applicantPhoneController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedNeighborhood;

  // Dinamik alanlar - is turune gore degisir
  Map<String, dynamic> get _dynamicFields => _workTypeFields[_selectedWorkType] ?? {};

  // Is turlerine gore dinamik alanlar
  static const Map<String, Map<String, dynamic>> _workTypeFields = {
    'Asfalt Onarım': {
      'fields': [
        {'label': 'Tahmini Alan (m²)', 'type': 'number', 'required': true},
        {'label': 'Hasar Tipi', 'type': 'select', 'options': ['Çukur', 'Çatlak', 'Yüzey Bozulması', 'Altyapı Kaynaklı'], 'required': true},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': true},
        {'label': 'Konum', 'type': 'location', 'required': false},
      ],
    },
    'Su Arızası': {
      'fields': [
        {'label': 'Arıza Tipi', 'type': 'select', 'options': ['Patlak', 'Sızıntı', 'Basınç Düşüklüğü', 'Kesinti'], 'required': true},
        {'label': 'Etkilenen Hane Sayısı', 'type': 'number', 'required': false},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': true},
        {'label': 'Konum', 'type': 'location', 'required': true},
      ],
    },
    'Kanalizasyon Tıkanıklığı': {
      'fields': [
        {'label': 'Taşma Var mı?', 'type': 'select', 'options': ['Evet', 'Hayır'], 'required': true},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': true},
        {'label': 'Konum', 'type': 'location', 'required': true},
      ],
    },
    'Ağaç Budama': {
      'fields': [
        {'label': 'Ağaç Sayısı', 'type': 'number', 'required': true},
        {'label': 'Risk Durumu', 'type': 'select', 'options': ['Elektrik Hattı Teması', 'Yola Sarkma', 'Kuru Dal', 'Devrilme Riski'], 'required': true},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': false},
      ],
    },
    'Aydınlatma Arızası': {
      'fields': [
        {'label': 'Arıza Tipi', 'type': 'select', 'options': ['Yanmıyor', 'Titriyor', 'Kırık Direk', 'Kablo Sorunu'], 'required': true},
        {'label': 'Direk/Armatür Sayısı', 'type': 'number', 'required': true},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': false},
      ],
    },
    'Kaldırım Onarım': {
      'fields': [
        {'label': 'Hasar Tipi', 'type': 'select', 'options': ['Kırık Taş', 'Çökme', 'Yükseklik Farkı', 'Eksik Taş'], 'required': true},
        {'label': 'Tahmini Uzunluk (m)', 'type': 'number', 'required': true},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': true},
      ],
    },
    'Trafik İşareti': {
      'fields': [
        {'label': 'İşaret Tipi', 'type': 'select', 'options': ['Dur Tabelası', 'Yön Tabelası', 'Hız Sınırı', 'Uyarı Levhası', 'Diğer'], 'required': true},
        {'label': 'Durum', 'type': 'select', 'options': ['Devrilmiş', 'Hasarlı', 'Eksik', 'Görünmüyor'], 'required': true},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': true},
        {'label': 'Konum', 'type': 'location', 'required': true},
      ],
    },
    'Çevre Düzenleme': {
      'fields': [
        {'label': 'İş Detayı', 'type': 'select', 'options': ['Ot Temizliği', 'Çim Biçme', 'Çiçek Dikimi', 'Peyzaj'], 'required': true},
        {'label': 'Tahmini Alan (m²)', 'type': 'number', 'required': false},
        {'label': 'Fotoğraf', 'type': 'photo', 'required': false},
      ],
    },
  };

  static const List<String> _workTypes = [
    'Asfalt Onarım', 'Su Arızası', 'Kanalizasyon Tıkanıklığı',
    'Ağaç Budama', 'Aydınlatma Arızası', 'Kaldırım Onarım',
    'Trafik İşareti', 'Çevre Düzenleme', 'Çöp Toplama',
    'Boya Badana', 'Park Bakım', 'Tretuar Döşeme',
    'Elektrik Arızası', 'Kazı İzni Denetimi',
  ];

  static const List<String> _districts = ['Yeşilyurt', 'Battalgazi'];

  static const Map<String, List<String>> _neighborhoods = {
    'Yeşilyurt': ['Tecde', 'İnönü', 'Yakınca', 'Çilesiz', 'Dilek', 'Bostanbaşı'],
    'Battalgazi': ['Uçbağlar', 'Bahçelievler', 'Çilesiz', 'Hoca Ahmet Yesevi', 'Bulgurlu'],
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _applicantNameController.dispose();
    _applicantPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İş Emri'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalLg,

              // Is turu
              Text('İş Türü *', style: Theme.of(context).textTheme.titleSmall),
              AppSpacing.verticalSm,
              DropdownButtonFormField<String>(
                value: _selectedWorkType, // ignore: deprecated_member_use
                decoration: const InputDecoration(hintText: 'İş türü seçin'),
                items: _workTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedWorkType = v),
                validator: (v) => v == null ? 'İş türü seçiniz' : null,
              ),
              AppSpacing.verticalLg,

              // Oncelik
              Text('Öncelik *', style: Theme.of(context).textTheme.titleSmall),
              AppSpacing.verticalSm,
              SegmentedButton<WorkPriority>(
                segments: WorkPriority.values.map((p) => ButtonSegment(
                  value: p,
                  label: Text(p.label, style: const TextStyle(fontSize: 11)),
                  icon: Icon(p.icon, size: 14),
                )).toList(),
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              AppSpacing.verticalLg,

              // Adres
              Text('Konum Bilgisi *', style: Theme.of(context).textTheme.titleSmall),
              AppSpacing.verticalSm,
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDistrict, // ignore: deprecated_member_use
                      decoration: const InputDecoration(hintText: 'İlçe'),
                      items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() {
                        _selectedDistrict = v;
                        _selectedNeighborhood = null;
                      }),
                      validator: (v) => v == null ? 'Seçiniz' : null,
                    ),
                  ),
                  AppSpacing.horizontalMd,
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedNeighborhood, // ignore: deprecated_member_use
                      decoration: const InputDecoration(hintText: 'Mahalle'),
                      items: (_neighborhoods[_selectedDistrict] ?? [])
                          .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedNeighborhood = v),
                      validator: (v) => v == null ? 'Seçiniz' : null,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Cadde / Sokak / Bina No',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              AppSpacing.verticalLg,

              // Aciklama
              Text('Açıklama *', style: Theme.of(context).textTheme.titleSmall),
              AppSpacing.verticalSm,
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'İş emri detaylarını yazın...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Açıklama giriniz' : null,
              ),
              AppSpacing.verticalLg,

              // Basvuran
              Text('Başvuran Bilgileri', style: Theme.of(context).textTheme.titleSmall),
              AppSpacing.verticalSm,
              TextFormField(
                controller: _applicantNameController,
                decoration: const InputDecoration(hintText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              AppSpacing.verticalMd,
              TextFormField(
                controller: _applicantPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Telefon', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              AppSpacing.verticalLg,

              // Dinamik alanlar - is turune gore
              if (_selectedWorkType != null && _dynamicFields.isNotEmpty) ...[
                Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                AppSpacing.verticalMd,
                Text(
                  '$_selectedWorkType - Ek Bilgiler',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                ),
                AppSpacing.verticalMd,
                ...(_dynamicFields['fields'] as List).map<Widget>((field) {
                  final label = field['label'] as String;
                  final type = field['type'] as String;
                  final required = field['required'] as bool;
                  final options = field['options'] as List<String>?;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildDynamicField(context, label, type, required, options, isDark),
                  );
                }),
              ],

              AppSpacing.verticalXl,

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('İş Emri Oluştur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicField(BuildContext context, String label, String type, bool required, List<String>? options, bool isDark) {
    switch (type) {
      case 'select':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: '$label${required ? ' *' : ''}'),
          items: options?.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (_) {},
          validator: required ? (v) => v == null ? 'Seçiniz' : null : null,
        );
      case 'number':
        return TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '$label${required ? ' *' : ''}'),
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Giriniz' : null : null,
        );
      case 'photo':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label${required ? ' *' : ''}', style: Theme.of(context).textTheme.labelMedium),
            AppSpacing.verticalSm,
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Kamera'),
                ),
                AppSpacing.horizontalSm,
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Galeri'),
                ),
              ],
            ),
          ],
        );
      case 'location':
        return OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.my_location_rounded, size: 18),
          label: Text('Konum Al${required ? ' *' : ''}'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        );
      default:
        return TextFormField(
          decoration: InputDecoration(labelText: '$label${required ? ' *' : ''}'),
          maxLines: type == 'textarea' ? 3 : 1,
        );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İş emri başarıyla oluşturuldu!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
