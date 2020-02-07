import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// Inserir a KEY criada no site https://console.hgbrasil.com/documentation/finance
const urlRequest = "https://api.hgbrasil.com/finance?key=xxxxxxxx";

void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))
      ),
      hintColor: Colors.amber,
      primaryColor: Colors.white
    )
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dolar;
  double euro;
  double bitcoin;

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    bitcoinController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toString();
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double _dolar = double.parse(text);
    realController.text = (_dolar * dolar).toStringAsFixed(2);
    euroController.text = (_dolar * dolar / euro).toStringAsFixed(2);
    bitcoinController.text = (_dolar * dolar / bitcoin).toString();
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double _euro = double.parse(text);
    realController.text = (_euro * euro).toStringAsFixed(2);
    dolarController.text = (_euro * euro / dolar).toStringAsFixed(2);
    bitcoinController.text = (_euro * euro / bitcoin).toString();
  }

  void _bitcoinChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double _bitcoin = double.parse(text);
    realController.text = (_bitcoin * bitcoin).toStringAsFixed(2);
    dolarController.text = (_bitcoin * bitcoin / dolar).toStringAsFixed(2);
    euroController.text = (_bitcoin * bitcoin / euro).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Conversor de Moedas",
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        // ignore: missing_return
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0
                  ),
                ),
              );
            default:
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ),
                  ),
                );
              else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                bitcoin = snapshot.data['results']['currencies']['BTC']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "USD\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
                      Divider(),
                      buildTextField("Bitcoin", "BTC", bitcoinController, _bitcoinChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller,
    Function func) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    controller: controller,
    decoration: InputDecoration(
      labelText: "$label",
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: "$prefix ",
    ),
    style: TextStyle(color: Colors.amber, fontSize: 20.0),
    onChanged: func,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(urlRequest);
  return json.decode(response.body);
}