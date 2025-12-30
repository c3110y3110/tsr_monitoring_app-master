import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsr_monitoring_app/util/constants.dart';
import 'package:tsr_monitoring_app/util/unique_shared_preference.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  final _maxvalueController = TextEditingController();
  final _minvalueController = TextEditingController();
  late List<String> _selectedMachines;
  final List<String> _allMachines = List<String>.from(machineList);
  @override
  void initState() {
    super.initState();
    final saved = UniqueSharedPreference.getStringList('selectedMachines', _allMachines);
    _selectedMachines = saved.isEmpty ? List<String>.from(_allMachines) : List<String>.from(saved);
  }
  @override
  Widget build(BuildContext context) {
    double curWidth = MediaQuery.of(context).size.width;
    if(curWidth >= 768) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Icon(Icons.arrow_back)),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("설정", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),)
                    ],
                  )
              )
            ],
          ),
          Expanded(child: _buildSetting(context)),
        ]
      );
    } else {
      return Padding(
          padding: const EdgeInsets.all(5),
          child: ListView(
              children: [
                Align(alignment: Alignment.center, child: Text("설정", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),),),
                _buildSetting(context),
              ]
          )
      );
    }
  }

  Widget _buildSetting(BuildContext context) {
    return Column(
      children: [
        Text("실시간 차트 최댓값"),
        Padding(padding: EdgeInsets.only(top: 20)),
        TextField(
          keyboardType: TextInputType.number,
          controller: _maxvalueController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '최댓값 ',
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Text("실시간 차트 최솟값"),
        Padding(padding: EdgeInsets.only(top: 20)),
        TextField(
          keyboardType: TextInputType.number,
          controller: _minvalueController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: '최솟값',
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Text("메인 화면에 표시할 장비"),
        ..._allMachines.map((machineName) {
          final bool isSelected = _selectedMachines.contains(machineName);
          return CheckboxListTile(
            value: isSelected,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(machineName),
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  if (!_selectedMachines.contains(machineName)) {
                    _selectedMachines.add(machineName);
                  }
                } else {
                  _selectedMachines.remove(machineName);
                }
              });
            },
          );
        }).toList(),
        Padding(padding: EdgeInsets.only(top: 20)),
        ElevatedButton(
          onPressed: () => {
            _saveValue()
          },
          child: Text("저장", style: TextStyle(fontSize: 24),))
      ],
    );
  }

  void _saveValue() {
    if (_selectedMachines.isEmpty) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("최소 1개 장비를 선택해주세요."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("확인")
                )
              ],
            );
          }
      );
      return;
    }
    try {
      final maxText = _maxvalueController.text.trim();
      final minText = _minvalueController.text.trim();
      if (maxText.isNotEmpty) {
        double.parse(maxText);
        UniqueSharedPreference.setString("maxvalue", maxText);
      }
      if (minText.isNotEmpty) {
        double.parse(minText);
        UniqueSharedPreference.setString("minvalue", minText);
      }
      UniqueSharedPreference.setStringList("selectedMachines", _selectedMachines);
      Navigator.of(context).pop();
    } catch(e) {
      _maxvalueController.clear();
      _minvalueController.clear();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("숫자만 입력해주세요."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("확인")
                )
              ],
            );
          }
      );
    }
  }

  @override
  void dispose() {
    _maxvalueController.dispose();
    _minvalueController.dispose();
    super.dispose();
  }
}
