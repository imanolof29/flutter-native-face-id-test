import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget{

  static const platform = MethodChannel("faceid");

  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async{
            await _requestFaceId(context);
          },
          child: const Text("Request permissions"),
        ),
      ),
    );
  }

  Future<void> _requestFaceId(BuildContext context) async{
    try{
      final result = await platform.invokeMethod("faceid");
      if(result["error"] != null){
        throw BiometricIsNotAvailableException();
      }
      if(result["compatible"] == false){
        throw IphoneNotCompatibleException();
      }
      if(result["result"] == false){
        throw DefaultException();
      }
    }on PlatformException catch(e){
      print("PLATFORM EXCEPTION $e");
    }on IphoneNotCompatibleException catch(e){
      _showDialogError(context, e.title);
    }on BiometricIsNotAvailableException catch(_){
      AppSettings.openAppSettings();
    }on DefaultException catch(e){
      _showDialogError(context, e.title);
    }catch(e){
      print("CATCH GENERICO $e");
    }
  }

  _showDialogError(BuildContext context, String title){
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              child: const Text("Aceptar")
            )
          ],
        );
      }
    );
  }

}

abstract class CustomException implements Exception{
  final String title;
  CustomException(this.title);
}

class IphoneNotCompatibleException implements CustomException{
  @override
  String get title => "Este iphone no es compatible con la biometria";
}

class BiometricIsNotAvailableException implements CustomException{
  @override
  String get title => "Biometria no disponible en estos momentos";
}

class DefaultException implements CustomException{
  @override
  String get title => "Algo fue mal";
}