import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fonnx/models/msmarcoMiniLmL6V3/msmarco_mini_lm_l6_v3.dart';
import 'package:fonnx_example/padding.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class MsmarcoMiniLmL6V3Widget extends StatefulWidget {
  const MsmarcoMiniLmL6V3Widget({super.key});

  @override
  State<MsmarcoMiniLmL6V3Widget> createState() =>
      _MsmarcoMiniLmL6V3WidgetState();
}

class _MsmarcoMiniLmL6V3WidgetState extends State<MsmarcoMiniLmL6V3Widget> {
  bool? _verifyPassed;
  String? _speedTestResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heightPadding,
        Text(
          'MSMARCO MiniLM L6 V3',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        heightPadding,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _runVerificationTest,
              child: const Text('Test Correctness'),
            ),
            widthPadding,
            if (_verifyPassed == true)
              const Icon(
                Icons.check,
                color: Colors.green,
              ),
            if (_verifyPassed == false)
              const Icon(
                Icons.close,
                color: Colors.red,
              ),
          ],
        ),
        heightPadding,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _runSpeedTest,
              child: const Text('Test Speed'),
            ),
            widthPadding,
            if (_speedTestResult != null) Text(_speedTestResult!),
          ],
        ),
      ],
    );
  }

  void _runVerificationTest() async {
    final modelPath = await getModelPath('msmarcoMiniLmL6V3.onnx');
    final model = MsmarcoMiniLmL6V3.load(modelPath);
    final result = await model.getEmbeddingAsVector(
        MsmarcoMiniLmL6V3.tokenizer.tokenize('').first.tokens);
    final embedding = result;
    const expected = _msmarcoMiniLmL6V3ExpectedForEmptyString;
    final isNotMatch = embedding.indexed.any((outer) {
      final doesNot = outer.$2 != expected[outer.$1];
      // Use 4 significant figures.
      // Slight mismatch between iOS and macOS. For example:
      // "0.36081504821777344 but got 0.3608149588108063"
      final doesNotAt5 = doesNot &&
          outer.$2.toStringAsFixed(4) != expected[outer.$1].toStringAsFixed(4);
      if (doesNotAt5) {
        debugPrint('Expected ${expected[outer.$1]} '
            'but got ${outer.$2} at index ${outer.$1}');
      }

      return doesNotAt5;
    });
    setState(() {
      _verifyPassed = !isNotMatch;
    });
  }

  void _runSpeedTest() async {
    final string = await rootBundle.loadString('assets/text_sample.txt');
    final textAndTokens = MsmarcoMiniLmL6V3.tokenizer.tokenize(string);
    final path = await getModelPath('msmarcoMiniLmL6V3.onnx');
    final model = MsmarcoMiniLmL6V3.load(path);
    debugPrint('Loaded model');
    // Warm up. This is not necessary, but it's nice to do. Only the first call
    // to a model is slow.
    for (var i = 0; i < 5; i++) {
      await model.getEmbeddingAsVector(
        textAndTokens[i % textAndTokens.length].tokens,
      );
    }
    debugPrint('Warmed up');

    final stopwatch = Stopwatch()..start();
    var completed = 0;
    while (completed < 20) {
      await model.getEmbeddingAsVector(
          textAndTokens[completed % textAndTokens.length].tokens);
      completed++;
    }
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    final speed = (elapsed / completed.toDouble()).round();
    setState(() {
      _speedTestResult = '$speed ms for 400 words';
    });
  }
}

Future<String> getModelPath(String modelFilenameWithExtension) async {
  if (kIsWeb) {
    return 'assets/models/msmarcoMiniLmL6V3/$modelFilenameWithExtension';
  }
  final assetCacheDirectory =
      await path_provider.getApplicationSupportDirectory();
  final modelPath =
      path.join(assetCacheDirectory.path, modelFilenameWithExtension);

  File file = File(modelPath);
  bool fileExists = await file.exists();
  final fileLength = fileExists ? await file.length() : 0;

  // Do not use path package / path.join for paths.
  // After testing on Windows, it appears that asset paths are _always_ Unix style, i.e.
  // use /, but path.join uses \ on Windows.
  final assetPath =
      'assets/models/msmarcoMiniLmL6V3/${path.basename(modelFilenameWithExtension)}';
  final assetByteData = await rootBundle.load(assetPath);
  final assetLength = assetByteData.lengthInBytes;
  final fileSameSize = fileExists && fileLength == assetLength;
  if (!fileExists || !fileSameSize) {
    debugPrint(
        'Copying model to $modelPath. Why? Either the file does not exist (${!fileExists}), '
        'or it does exist but is not the same size as the one in the assets '
        'directory. (${!fileSameSize})');

    List<int> bytes = assetByteData.buffer.asUint8List(
      assetByteData.offsetInBytes,
      assetByteData.lengthInBytes,
    );
    await file.writeAsBytes(bytes, flush: true);
  }

  return modelPath;
}

const _msmarcoMiniLmL6V3ExpectedForEmptyString = [
  0.04374124854803085,
  -0.01092158816754818,
  -0.038760825991630554,
  -0.0040793344378471375,
  0.01169607974588871,
  -0.0446600615978241,
  0.010342326015233994,
  -0.015763241797685623,
  0.02806965261697769,
  0.009921246208250523,
  -0.0036930947098881006,
  -0.004229821264743805,
  -0.010592243634164333,
  -0.032352883368730545,
  0.0008156258263625205,
  -0.024753209203481674,
  -0.031149370595812798,
  -0.039560168981552124,
  0.041971273720264435,
  -0.008415305987000465,
  0.0128370001912117,
  -0.04187486320734024,
  0.029058625921607018,
  0.007055731024593115,
  -0.004894203040748835,
  0.01064298115670681,
  0.008102952502667904,
  -0.013229363597929478,
  -0.018574753776192665,
  -0.06602784246206284,
  0.015223694033920765,
  0.004584575537592173,
  0.01628745160996914,
  0.0064985197968780994,
  -0.04791625961661339,
  0.031493086367845535,
  0.005597034934908152,
  -0.009856377728283405,
  0.025455284863710403,
  0.0035207041073590517,
  -0.013316331431269646,
  0.010769108310341835,
  -0.013045134954154491,
  0.05022146552801132,
  0.04917237162590027,
  0.047894686460494995,
  -0.02680887281894684,
  0.022246943786740303,
  -0.02576562575995922,
  0.035638004541397095,
  0.008476519025862217,
  -0.06353423744440079,
  0.01433213148266077,
  -0.027376819401979446,
  -0.006872199941426516,
  0.044761933386325836,
  -0.010166998021304607,
  0.002277338644489646,
  -0.024693017825484276,
  0.032043520361185074,
  -0.034849029034376144,
  -0.04992201179265976,
  -0.0488353855907917,
  0.0037222420796751976,
  -0.038992442190647125,
  -0.03542392700910568,
  0.021671729162335396,
  -0.01316126063466072,
  -0.016401490196585655,
  0.015431822277605534,
  0.04596877843141556,
  0.0063309515826404095,
  -0.007250173017382622,
  0.0056274463422596455,
  -0.030273279175162315,
  0.002467002719640732,
  -0.028947576880455017,
  0.020841101184487343,
  0.030247116461396217,
  -0.01484737265855074,
  0.010031994432210922,
  0.016632890328764915,
  0.02555757388472557,
  -0.01628918945789337,
  0.03351643681526184,
  0.006067587528377771,
  0.016352545469999313,
  0.013014491647481918,
  0.0008667140500620008,
  0.0354158915579319,
  -0.009977957233786583,
  0.05917133763432503,
  0.024540012702345848,
  0.004017975647002459,
  0.027881145477294922,
  -0.02680320478975773,
  0.007597653660923243,
  -0.02504698745906353,
  0.018438035622239113,
  0.8328103423118591,
  -0.032059576362371445,
  -0.0010896989842876792,
  -0.02191096358001232,
  -0.007603100501000881,
  0.00378559366799891,
  -0.011440735310316086,
  0.023205390200018883,
  0.02450818195939064,
  0.015447254292666912,
  -0.02058940939605236,
  -0.014242186211049557,
  -0.024088026955723763,
  -0.005902535747736692,
  0.03162120655179024,
  0.0013469021068885922,
  -0.013955710455775261,
  0.01637219823896885,
  0.0364510640501976,
  0.060161832720041275,
  0.006708359345793724,
  0.00397687591612339,
  -0.007242530584335327,
  -0.02699577994644642,
  -0.004249170422554016,
  0.024402979761362076,
  -0.16737055778503418,
  -0.022192252799868584,
  -0.019193628802895546,
  -0.008167111314833164,
  -0.01987346261739731,
  0.04855317249894142,
  0.037574414163827896,
  0.00491249468177557,
  0.043691448867321014,
  0.004323604516685009,
  -0.017715618014335632,
  -0.006229477934539318,
  -0.008041215129196644,
  -0.03754253312945366,
  0.026529323309659958,
  -0.01230490393936634,
  0.0786948874592781,
  0.012537292204797268,
  0.028479689732193947,
  0.008634457364678383,
  -0.020188385620713234,
  0.016749173402786255,
  -0.054528024047613144,
  0.027426667511463165,
  0.010465899482369423,
  0.009991015307605267,
  -0.020127901807427406,
  -0.0015448530903086066,
  -0.016924742609262466,
  0.004590223077684641,
  -0.06101616472005844,
  0.005667444784194231,
  -0.07680987566709518,
  0.012677385471761227,
  0.02619941160082817,
  0.04107062891125679,
  0.023441117256879807,
  0.020447995513677597,
  -0.04291784018278122,
  0.012796726077795029,
  -0.01829553209245205,
  -0.01045321673154831,
  -0.010936945676803589,
  0.010635798797011375,
  0.01583845540881157,
  -0.008468256331980228,
  -0.02771110087633133,
  -0.01787947304546833,
  0.011790258809924126,
  -0.0854463279247284,
  -0.007195215672254562,
  -0.006644058506935835,
  0.03821655362844467,
  -0.004945063963532448,
  -0.005321079865098,
  -0.03564945608377457,
  0.0027496013790369034,
  -0.0323292538523674,
  -0.004239662084728479,
  0.00017076925723813474,
  0.01332303136587143,
  -0.017716726288199425,
  0.008937413804233074,
  0.00919654406607151,
  -0.026056334376335144,
  -0.015044940635561943,
  0.007164199836552143,
  -0.012236228212714195,
  0.0480746366083622,
  0.00341981602832675,
  -0.01090493518859148,
  -0.012277415953576565,
  -0.0025339387357234955,
  -0.01628798432648182,
  -0.02006612718105316,
  -0.07335218042135239,
  0.025096530094742775,
  0.03490757942199707,
  -0.02841583639383316,
  0.020523464307188988,
  -0.03302204981446266,
  0.015635423362255096,
  -0.008627877570688725,
  -0.015090426430106163,
  0.01481179241091013,
  -0.005267024040222168,
  -0.012645124457776546,
  0.024932358413934708,
  0.0009037258569151163,
  -0.007028630003333092,
  -0.012785476632416248,
  0.011466212570667267,
  0.014343992806971073,
  -0.0542178638279438,
  0.008290066383779049,
  -0.004100619815289974,
  0.013446162454783916,
  0.037655726075172424,
  -0.08169695734977722,
  -0.015271981246769428,
  -0.03202367573976517,
  -0.0332273431122303,
  -0.0207690317183733,
  -0.015957379713654518,
  -0.013101649470627308,
  -0.0017546883318573236,
  0.02766895480453968,
  -0.009762804955244064,
  -0.039693985134363174,
  -0.054052531719207764,
  0.0029138782992959023,
  -0.03630135953426361,
  0.015085350722074509,
  -0.034996215254068375,
  -0.028138794004917145,
  -0.021627940237522125,
  -0.018998855724930763,
  0.016254695132374763,
  0.019199859350919724,
  0.010765353217720985,
  -0.00017711370310280472,
  0.0031005244236439466,
  0.03729426860809326,
  -0.023137109354138374,
  0.008117363788187504,
  -0.054193321615457535,
  -0.01760070212185383,
  -0.004772305488586426,
  0.0510220006108284,
  -0.03783179074525833,
  -0.0159290824085474,
  0.03820422664284706,
  -0.049535661935806274,
  -0.004781421739608049,
  -0.010553913190960884,
  0.01342553086578846,
  -0.02271028608083725,
  0.02447683736681938,
  -0.0026799729093909264,
  -0.02713710255920887,
  -0.016062350943684578,
  0.026233818382024765,
  0.007122547831386328,
  -0.0027262840885668993,
  -0.012735576368868351,
  -0.00972361583262682,
  0.005891364999115467,
  -0.022233204916119576,
  -0.02467924728989601,
  -0.00612823199480772,
  0.023159658536314964,
  0.00814889743924141,
  -0.009933733381330967,
  0.03159722313284874,
  0.008188383653759956,
  -0.026636889204382896,
  -0.05323859304189682,
  -0.02575816586613655,
  0.06554427742958069,
  -0.005676175467669964,
  -0.03493901714682579,
  -0.026333408430218697,
  -0.002183068310841918,
  -0.005813625641167164,
  0.029104353860020638,
  0.04844416305422783,
  0.03716088458895683,
  -0.008052794262766838,
  -0.010289445519447327,
  -0.05186062306165695,
  -0.00752479862421751,
  -0.028273623436689377,
  0.02670607529580593,
  -0.019344357773661613,
  0.043466124683618546,
  0.02435658872127533,
  -0.0322503000497818,
  0.005788477603346109,
  0.02760990336537361,
  0.06096064671874046,
  -0.0063599515706300735,
  0.006435271352529526,
  0.009143559262156487,
  0.006911716889590025,
  -0.010082005523145199,
  -0.05752233415842056,
  -0.035066116601228714,
  0.03946138173341751,
  0.019407298415899277,
  0.026196720078587532,
  0.01646880991756916,
  -0.04891708120703697,
  -0.0036562897730618715,
  -0.019103096798062325,
  -0.055524859577417374,
  -0.055092476308345795,
  0.013741993345320225,
  0.01826968975365162,
  0.02318430505692959,
  0.060339704155921936,
  -0.01845398359000683,
  -0.04917540401220322,
  0.04054601490497589,
  -0.010154804214835167,
  -0.03180001676082611,
  -0.015370034612715244,
  0.016963442787528038,
  -0.00377458892762661,
  -0.03043145313858986,
  -0.017864199355244637,
  -0.00934278592467308,
  0.02302599512040615,
  -0.029923904687166214,
  0.033621709793806076,
  0.007498262915760279,
  0.02134578488767147,
  -0.038182880729436874,
  0.0010924716480076313,
  0.01981048472225666,
  0.027095559984445572,
  0.01589326187968254,
  0.012174719013273716,
  -0.04865756630897522,
  0.0026259312871843576,
  0.014425135217607021,
  -0.023836258798837662,
  -0.017786381766200066,
  -0.0029388428665697575,
  -0.05026664584875107,
  -0.033478982746601105,
  0.021702948957681656,
  -0.028356734663248062,
  0.0018228961853310466,
  -0.007562174461781979,
  0.011414878070354462,
  -0.024140510708093643,
  0.029025470837950706,
  0.005896927323192358,
  -0.013562846928834915,
  0.023830842226743698,
  0.02341400273144245,
  -0.01257307268679142,
  -0.009114688262343407,
  0.02235519513487816,
  0.01286843977868557,
  -0.01890745386481285,
  -0.01080723013728857,
  0.01945212297141552,
  -0.03122428059577942,
  -0.004073023330420256,
  0.03286336734890938,
  0.01164075918495655,
  0.04158680513501167,
  -0.001354328589513898,
  0.04135201498866081,
  -0.006318759638816118,
  -0.008155220188200474,
  0.0016958838095888495,
  0.018184928223490715,
];
