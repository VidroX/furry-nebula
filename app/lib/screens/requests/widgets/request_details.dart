import 'package:flutter/material.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';

class RequestDetails extends StatefulWidget {
  final UserRequest request;

  const RequestDetails({
    required this.request,
    super.key,
  });

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  @override
  Widget build(BuildContext context) => const Placeholder();
}
