import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:snapsdi/main.dart' as snapsdi;
import 'package:snapsdi/views/home_page.dart';


void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end to end  test', (){
    testWidgets(
      'verifying login', 
      (tester) async{
        snapsdi.main();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0),'shahxyz@gmail.com' );
        await tester.enterText(find.byType(TextField).at(1),'qwerty' );
        await tester.tap(find.byType(ElevatedButton));
      },
      );
  });
}
