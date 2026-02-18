import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';


class DecisionsListPage extends StatelessWidget {
  const DecisionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DecisionsListWidget(refetch:true);
  }
}
