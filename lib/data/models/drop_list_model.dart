import 'package:flutter/material.dart';

class DropListModel {
  DropListModel(this.listOptionItems);

  final List<OptionItem> listOptionItems;
}

class OptionItem {
  final String id;
  final String title;

  OptionItem({required this.id, required this.title});
}

class SelectDropList extends StatefulWidget {
  final OptionItem itemSelected;
  final DropListModel dropListModel;
  final Function(OptionItem optionItem) onOptionSelected;

  const SelectDropList(this.itemSelected, this.dropListModel, this.onOptionSelected, {super.key});

  @override
  _SelectDropListState createState() => _SelectDropListState(itemSelected, dropListModel);
}

class _SelectDropListState extends State<SelectDropList> with SingleTickerProviderStateMixin {
  OptionItem optionItemSelected;
  final DropListModel dropListModel;

  late AnimationController expandController;
  late Animation<double> animation;

  bool isShow = false;

  _SelectDropListState(this.optionItemSelected, this.dropListModel);

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350)
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    _runExpandCheck();
  }

  void _runExpandCheck() {
    if (isShow) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.transparent,
              border: Border.all(color: const Color(0xFFE4DFDF)),
              
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.list_rounded, color: Color(0xFFE4DFDF)),
                const SizedBox(width: 10),
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isShow = !isShow;
                          _runExpandCheck();
                        });
                      },
                      child: Text(optionItemSelected.title, style: const TextStyle(
                          color: Color(0xFF0A0A0A),
                          fontSize: 16)),
                    )
                ),
                Align(
                  alignment: const Alignment(1, 0),
                  child: Icon(
                    isShow ? Icons.arrow_drop_down_sharp : Icons.arrow_right,
                    color: const Color(0xFF0A5338),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: animation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, top: 8),
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black26,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildDropListOptions(dropListModel.listOptionItems, context),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildDropListOptions(List<OptionItem> items, BuildContext context) {
  return SizedBox(
    height: items.length > 5 ? 250 : null, // Adjust height
    child: ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildSubMenu(items[index], context);
      },
    ),
  );
}


  Widget _buildSubMenu(OptionItem item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26.0, top: 5, bottom: 5),
      child: GestureDetector(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
                ),
                child: Text(item.title,
                    style: const TextStyle(
                        color: Color(0xFF0A5338),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            optionItemSelected = item;
            isShow = false;
            expandController.reverse();
            widget.onOptionSelected(item);
          });
        },
      ),
    );
  }
}


