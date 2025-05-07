import 'package:flutter/material.dart';
import 'package:gorsel_programlama_proje/services/question_create_service.dart';

class QuizQuestionAddPage extends StatefulWidget {
  const QuizQuestionAddPage({Key? key}) : super(key: key);

  @override
  _QuizQuestionAddPageState createState() => _QuizQuestionAddPageState();
}

class _QuizQuestionAddPageState extends State<QuizQuestionAddPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String _questionText = '';
  String _optionA = '';
  String _optionB = '';
  String _optionC = '';
  String _optionD = '';
  String? _correctOption;
  int _difficulty = 1;

  final List<String> _categories = ['Genel Kültür', 'Bilim', 'Spor', 'Tarih'];
  final List<String> _optionsLabels = ['A', 'B', 'C', 'D'];

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();

    int correctAnswerIndex = _optionsLabels.indexOf(_correctOption!);

    final Map<String, dynamic> questionData = {
      'questionText': _questionText,
      'optionA': _optionA,
      'optionB': _optionB,
      'optionC': _optionC,
      'optionD': _optionD,
      'correctAnswerIndex': correctAnswerIndex,
      'category': _selectedCategory!,
      'difficulty': _difficulty,
      'scores': 0,
    };

    final success = await QuestionCreateService.createQuestion(
      questionData: questionData,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '🎉 Soru başarıyla kaydedildi!' : '❌ Kaydetme başarısız!',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    if (success) {
      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = null;
        _correctOption = null;
        _difficulty = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🧠 Soru Hazırlama Zamanı!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.pinkAccent,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F0071), Color(0xFF15002B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildGlassCard(
                    child: DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('📚 Kategori'),
                      dropdownColor: const Color(0xFF3A003A),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      value: _selectedCategory,
                      items:
                          _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => _selectedCategory = val),
                      validator:
                          (v) => v == null ? 'Lütfen kategori seçiniz' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: _buildTextFormField(
                      '❓ Soru',
                      onSaved: (val) => _questionText = val!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: _buildTextFormField(
                      'A Şıkkı',
                      onSaved: (val) => _optionA = val!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: _buildTextFormField(
                      ' B Şıkkı',
                      onSaved: (val) => _optionB = val!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: _buildTextFormField(
                      ' C Şıkkı',
                      onSaved: (val) => _optionC = val!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: _buildTextFormField(
                      ' D Şıkkı',
                      onSaved: (val) => _optionD = val!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('✅ Doğru Şık'),
                      dropdownColor: const Color(0xFF3A003A),
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      value: _correctOption,
                      items:
                          _optionsLabels
                              .map(
                                (o) =>
                                    DropdownMenuItem(value: o, child: Text(o)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _correctOption = val),
                      validator:
                          (v) => v == null ? 'Doğru şıkkı seçiniz' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    child: Column(
                      children: [
                        Text(
                          '🔥 Zorluk: $_difficulty',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _difficulty.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged:
                              (val) =>
                                  setState(() => _difficulty = val.toInt()),
                          activeColor: Colors.amber,
                          inactiveColor: Colors.white30,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _submit,

                    label: const Text('🚀 Soruyu Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB800E6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 12,
                      shadowColor: Colors.pinkAccent,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }

  TextFormField _buildTextFormField(
    String label, {
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      decoration: _buildInputDecoration(label),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      onSaved: onSaved,
      validator: (v) => v == null || v.isEmpty ? '$label zorunlu' : null,
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
