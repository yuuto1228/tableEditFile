import 'dart:html';
import 'dart:js';

import 'package:firebase/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';

final emailInputController = new TextEditingController();
final passwordInputController = new TextEditingController();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      MyItemsPage.routeName: (BuildContext context) => new MyItemsPage(title: "MyItemsPage"),
      MyHomePage.routeName: (BuildContext context) => new MyHomePage(title: "MyHomePage"),
    };
    return new MaterialApp(
      title: 'TableEdit Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: new MyHomePage(title: 'TableEdit Demo'),
      home: new LoginAndInfo(title: "LoginPage",),
      routes: routes,
      /*
      routes: {
        '/': (context) => new MyHomePage(),
        '/MyItemsPage': (context) => MyItemsPage(),
      }
       */
    );
  }
}

class LoginAndInfo extends StatefulWidget{
  LoginAndInfo({Key key, this.title}) : super(key: key);
  static const String routeName = "/LoginAndInfo";
  final String title;
  @override
  _LoginAndInfo createState() => new _LoginAndInfo();
}
class _LoginAndInfo extends State<LoginAndInfo>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Login"),
      ),
      body: Center(
        child: new Form(
          child: new SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("表形式のメモを管理できるアプリの予定です。汎用性高めていきたいです。"),
                Text("登録の部分作る時間無かったのでゲストDemo版のみです。"),
                Text("一応メール・パスワード認証とGoogle認証は裏で動いてますが登録と管理の実装は時間無かったです。"),
                Text("細かいとこ雑です。そのうち直します。"),
                const SizedBox(height: 24.0),
                new Center(
                  child: new RaisedButton(
                    child: Text('Guest Login'),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pushNamed(context, MyHomePage.routeName);

                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                new TextFormField(
                  controller: emailInputController,
                  decoration: const InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 24.0),
                new TextFormField(
                  controller: passwordInputController,
                  decoration: new InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),
                new Center(
                  child: new RaisedButton(
                    child: const Text(' Login '),
                    onPressed: () {
                      var email = emailInputController.text;
                      var password = passwordInputController.text;
                      // ここにログイン処理を書く
                      return _signIn(email, password)//←こんな感じで呼ぶ
                        .then((AuthResult result) => print(result.user))
                        .catchError((e) => print(e));
                    },
                  ),
                  ),
                const SizedBox(height: 12.0),
                new Center(
                  child: new RaisedButton(
                    child: const Text('with Google'),
                    color: Colors.red,
                    onPressed: () {

                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<AuthResult> _signIn(String email, String password) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    print("User id is ${result.user.uid}");
    return result;
  }

}



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  static const String routeName = "/MyHomePage";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var count = 1;
  String m_inputedValue="";
  String type = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TableEdit Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  )
                ),
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Use Template..."),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("時間割"),
                          color: Colors.cyanAccent,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                          type="時間割";
                          createTemplateCollection(context, type);
                          }
                        ),
                        SizedBox(width: 10,),
                        RaisedButton(
                          child: Text("QCD"),
                          color: Colors.cyanAccent,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                            type="QCD";
                            createTemplateCollection(context, type);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FlatButton(
                //onPressed: (){showDemoDialog(context);},
                onPressed: (){createNewCollection(context);},
                child: Icon(Icons.add),
              ),
              Flexible(
                child: createListView("TableList", "A"),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDemoDialog(context);
            //Navigator.pushNamed(context, MyItemsPage.routeName);
            //Navigator.pushNamed(context, "/MyItemPage");
          },
          child: Icon(Icons.add),
        ),
    );
  }

  //Create_NewCollection
  createNewCollection(context){
    /*
    必要な情報
    ・テーブル名
    ・列数、列名
     */
    //debugPrint("createNewCollection");
    showCreateCollectionDialog(context);
    //debugPrint("/createNewCollection");
  }


  addNewCollection(name,keys){
    //debugPrint("addNewCollection");
    Map<String,dynamic> data = new Map<String,dynamic>();
    //debugPrint(keys.toString());
    for (int i=0;i<keys.length;i++){
      data[keys[i]] = " ";
    }

    Firestore.instance.collection(name).add(data);//reloadを入れなきゃいけない

    Map<String,dynamic> listData = new Map<String,dynamic>();
    listData["A"] = name;
    Firestore.instance.collection("TableList").add(listData);

    setState(() {});

  }

  showCreateCollectionDialog (context){
    var _newName = "";
    var _newKeys = [];
    var newNameCnt = new TextEditingController();
    var columnControllers =[TextEditingController()];
    List<Widget> columnList = [];
    debugPrint("/showCreateCollection");
    debugPrint(columnList.length.toString());
    bool _flag = true;

    Widget initColumnTextField(){
        Widget columnName =
          TextField(
            controller: columnControllers[columnControllers.length-1],
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              //labelText: "value input",
              hintText: "Column Name",
            ),
            onChanged: (text){
              _flag = true;
            },
          );
        return columnName;
    }


    columnList =[
      initColumnTextField(),
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Create New Table"),
              content: Column( //column1
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: newNameCnt,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        //labelText: "value input",
                        hintText: "Table Name",
                      ),
                      onChanged: (text) {
                        // 入力値を変数に格納する。
                        setState(() {});
                      }
                  ),
                  Column( //column2
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: columnList,
                  ), //column2
                  FlatButton(
                    onPressed: () {
                      columnControllers.add(new TextEditingController());
                      debugPrint(columnControllers.length.toString());
                      columnList.add(initColumnTextField());
                      //debugPrint(columnList.length.toString());
                      setState(() {});
                    },
                    child: Icon(Icons.add),
                  ),

                ],), //column1
              //content: Row(
              //children: [
              //Text(value)
              //],

              actions: <Widget>[
                FlatButton(
                  child: const Text("CreateTable"),
                  onPressed: () {
                    _newName = newNameCnt.text;
                    for (int i=0;i<columnControllers.length;i++){
                      if (columnControllers[i].text.length==0){
                        debugPrint(columnControllers[i].text.length.toString());
                        _flag = false;
                      }
                    }
                    if (_flag==true){
                      for (int i=0;i<columnControllers.length;i++) {
                        _newKeys.add(columnControllers[i].text);
                      }
                      debugPrint(_newName);
                      debugPrint(_newKeys.toString());
                      addNewCollection(_newName, _newKeys);
                      Navigator.of(context).pop();
                      //showDemoDialog(context);
                    }else{

                    }

                  },
                ),
              ],

            );
          },
        );
      },

    );//showdialog
  }//showEditdialog
  createTemplateCollection(context,type){
    var newName = type;
    var newKeys = [];
    var newTmpNameCnt = new TextEditingController(text: type);
    bool flag = true;

    //template指定
    if(type=="時間割"){
      newKeys = ["時間","月","火","水","木","金","土","日"];

    }else if(type=="QCD"){
      newKeys = ["Quality（品質）","Cost（原価）","Delivery（納期）"];

    }

    showDialog(
      context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Create New " + type + "Table"),
                content: Column( //column1
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                        controller: newTmpNameCnt,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          //labelText: "value input",
                          hintText: "Table Name",
                        ),
                        onChanged: (text) {
                          // 入力値を変数に格納する。
                          flag = true;
                          //setState(() {});
                        }
                    ),
                  ],
                ),

                actions: <Widget>[
                  FlatButton(
                    child: const Text("CreateTable"),
                    onPressed: () {
                      if (newTmpNameCnt.text.length == 0) {
                        flag = false;
                      }
                      if (flag == true) {
                        newName = newTmpNameCnt.text;
                        debugPrint(newName);
                        debugPrint(newKeys.toString());
                        addNewCollection(newName, newKeys);
                        Navigator.of(context).pop();
                        //showDemoDialog(context);
                      }
                    },
                  ),
                ],

              );
            },
          );
        }

    );

  }

  _createChildren(cols){
    Widget columnName =
    TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          //labelText: "value input",
          hintText: "Column Name",
        ),
        onChanged: (text) {
          // 入力値を変数に格納する。
          setState(() {
          });
        }
    );
    List<Widget> columnList =[
      columnName,
    ];
    for (int i=0;i<cols;i++){
      columnList.add(columnName);
    }
    return  columnList;
  }
}

class MyItemsPage extends StatefulWidget {
  MyItemsPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";

  final String title;

  @override
  _MyItemsPageState createState() => new _MyItemsPageState();
}


class _MyItemsPageState extends State<MyItemsPage> {
  String _value="";
  List _keys=[];
  List _docs = [];
  var _args;
  void _setValue(String value) => setState(()=>_value = value);

  @override
  Widget build(BuildContext context) {
    var button = new IconButton(icon: new Icon(Icons.arrow_back), onPressed: _onButtonPressed);
    var args = ModalRoute.of(context).settings.arguments;
    _args = args;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(args),
      ),
      body: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[


        FlatButton(
          onPressed: () {
          },
          child: Text("遊び心"),
        ),
        Flexible(
          //child: createListView2(args, "ID"),
          child: createDataTable(args),
        ),
        Container(//調整用のcontainer
          margin: EdgeInsets.only(top:15),
          width: 30,
          height: 30,
          child: FloatingActionButton(
            onPressed: (){addRow(args);},
            tooltip: 'Add',
            child: new Icon(Icons.add),
          )
        ),
      ],
    ),
      ),
    );
  }

  void _onFloatingActionButtonPressed() {
  }

  void _onButtonPressed() {
    //Navigator.pop(context);
  }

  deleteRow(index,context){
    //print("deleteButton:"+index.toString());
    if(_docs.length==1){
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("行を完全に削除することはできません。"),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: Text("ごめんなさいボタン"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }else {
      Firestore.instance.collection(_args)
          .document(_docs[index].documentID)
          .delete();
    }
  }






  //Create_NewColumn

  //Read
  createDataTable(collname){//collname = コレクションの名前

    return StreamBuilder(
      stream: Firestore.instance.collection(collname).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // エラーの場合
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // 通信中の場合
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading ...');
          default:
            //debugPrint("createDataTable");

            List<DocumentSnapshot> docs = snapshot.data.documents;
            var id = docs[0].documentID;
            var keys = docs[0].data.keys.toList();
            var value = docs[0][keys[0]];//できてない
            _keys = keys;
            _docs = docs;
            //debugPrint(id);
            //debugPrint(keys.toString());
            //debugPrint(value);
            //debugPrint(_keys.toString());
            List<DataColumn> columns= [];

            columns.add(DataColumn(label:Text("Delete")));
            for (int i=0;i<keys.length;i++){
              columns.add(DataColumn(label: Text(keys[i]),onSort: (i,b){}));
            }


            return DataTable(
              onSelectAll: (b){},
              sortColumnIndex: 1,
              sortAscending: false,
              columns: columns,
              rows: createDataTableRows(collname,docs,keys,context),
            );
        }
      },
    );
  }//createDataTable

  createDataTableRows(collname,docs,keys,context){
    List<DataRow> rowList = [];


    //debugPrint(docs.length.toString());
    //debugPrint(keys.length.toString());
    
    for (int i=0;i<docs.length;i++) {//document(行)を回す
      List<DataCell> cells = [];
      var delbutton = FlatButton(
        onPressed: () {
          deleteRow(i,context);
        },
        child: Icon(Icons.delete),
      );
      cells.add(DataCell(delbutton));
      for (int j = 0; j < keys.length; j++) {//key(を)回す
        //cells.add(DataCell(deleteRow(i)));

        var value = docs[i][keys[j]];
        cells.add(
            DataCell(
                Text(value),
                onTap: (){showEditDialog(context,value,collname,docs,keys,i,j);
                //onTap: (){
                  //debugPrint(docs[i][keys[j]]);
                })
        );
      }
      rowList.add(
          DataRow(
            selected: false,
              /*
              onSelectChanged: (b){
              print("onSelect");
              print(i);
              },

               */
              cells: cells
          )
      );
    }
    //debugPrint(rowList.toString());
    return rowList;

  }

  onSelectedRow(bool selected,User user){

  }

  //Update
  showEditDialog (context,value,collname,docs,keys,i,j){
    var inputValue = value;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Edit Value"),
          content: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              //labelText: "value input",
              hintText: value,
            ),
        onChanged: (text) {
          // 入力値を変数に格納する。
          setState(() {
            _keys = keys;
            inputValue = text;
          });
        }

            // 変更を反映する。

          ),
          //content: Row(
            //children: [
              //Text(value)
            //],

          actions: <Widget>[
            FlatButton(
              child: const Text("OK!!!!"),
              onPressed: (){
                if (inputValue != value) {
                  DataUpdate(inputValue,collname,docs,keys,i,j);
                }
                Navigator.of(context).pop();
              },
            ),
          ],

        );
      },

    );//showdialog
  }//showEditdialog

  //dialogでの編集を反映する（DataTableだけ更新か、Firestore更新か）
  DataUpdate(inputedValue,collname,docs,keys,i,j){//必要なのは更新値と更新先
    /*
    debugPrint("DataUpdate");
    debugPrint(collname);
    debugPrint(docs[i].toString());
    debugPrint(keys[j]);
    */

    Firestore.instance
        .collection(collname)
        .document(docs[i].documentID)
        .updateData({keys[j]:inputedValue});
  }


  //Create_NewRow(document)
  addRow(collname){
    //debugPrint("addRow");
    Map<String,dynamic> key_value = new Map<String,dynamic>();
    //debugPrint(_keys.toString());
    for (int i=0;i<_keys.length;i++){
      key_value[_keys[i]] = " ";
    }
    Firestore.instance.collection(collname).add(key_value);

  }
}


createListView(collname,coluname) {
  var a = collname;
  var c = coluname;
  Firestore.instance.collection(collname).snapshots().listen((data) {
    print(data);//Firestoreのコレクション名[collname]を取得。例:TestTable1
  });

  return StreamBuilder(
    stream: Firestore.instance.collection(collname).snapshots(),//streamでリアルタイム通信
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      // エラーの場合
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      // 通信中の場合
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Text('Loading ...');
        default:
          return ListView(
            //shrinkWrap: true,   //追加
            //physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return new ListTile(
                title: new Text(document[coluname]),
                onTap: (){
                  //debugPrint(document[coluname]);

                  var selectTable = document[coluname];
                  Navigator.pushNamed(context, MyItemsPage.routeName,arguments: selectTable);
                },
                //subtitle: new Text(document['author']),
              );
            }).toList(),
          );
      }
    },
  );
}

showDemoDialog (context){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text("Sorry,"),
        content: Text("This feature is not available in the trial version."),
        //content: Row(
        //children: [
        //Text(value)
        //],

        actions: <Widget>[
          FlatButton(
            child: const Text("OK!!!!"),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
        ],

      );
    },

  );//showdialog
}//showEditdialog




