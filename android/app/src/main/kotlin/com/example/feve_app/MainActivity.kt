package com.example.feve_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "feve_channel"
    private lateinit var segmentationHelper: ImageSegmentationHelper
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        segmentationHelper = ImageSegmentationHelper(context)

        scope.launch {
            segmentationHelper.initSegmenter()
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getModelNames" -> {
                    val modelNames = segmentationHelper.getModelNames()
                    result.success(modelNames)
                }
                "selectModel" -> {
                    val modelName = call.argument<String>("modelName")
                    if (modelName != null) {
                        scope.launch {
                            try {
                                segmentationHelper.selectModel(modelName)
                                result.success(null)
                            } catch (e: Exception) {
                                result.error("SELECT_MODEL_ERROR", e.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Nome do modelo ausente", null)
                    }
                }
                "segmentImage" -> {
                    // Recebendo o array de bytes (Uint8List no Dart)
                    val imageBytes = call.argument<ByteArray>("imageBytes")

                    if (imageBytes != null) {
                        scope.launch {
                            try {
                                // Retorna um ByteArray de tamanho 65536 (256x256)
                                val maskBytes = segmentationHelper.segment(imageBytes)
                                if (maskBytes != null) {
                                    result.success(maskBytes)
                                } else {
                                    result.error("DECODE_ERROR", "Não foi possível decodificar a imagem a partir dos bytes fornecidos.", null)
                                }
                            } catch (e: Exception) {
                                result.error("INFERENCE_ERROR", e.message, null)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Bytes da imagem ausentes", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        segmentationHelper.cleanup()
    }
}