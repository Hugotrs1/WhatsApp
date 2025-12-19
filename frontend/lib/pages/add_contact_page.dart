import 'package:flutter/material.dart';

import '../styles/whatsapp_style.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: WhatsAppStyles.pagePadding,
      children: [
        Text(
          'Ajouter un contact',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Renseigne le nom et le numero pour demarrer une discussion.',
          style: WhatsAppStyles.mutedBodyStyle(context),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: WhatsAppStyles.formFieldDecoration(
                  label: 'Nom',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => _requiredValidator(value, 'Nom'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: WhatsAppStyles.formFieldDecoration(
                  label: 'Telephone',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (value) => _requiredValidator(value, 'Telephone'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: WhatsAppStyles.primaryButtonStyle,
                  child: const Text('Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact ajoute.')),
    );
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Merci de renseigner $label.';
    }
    return null;
  }
}
