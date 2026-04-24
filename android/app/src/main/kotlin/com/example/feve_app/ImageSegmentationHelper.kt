package com.example.feve_app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.SystemClock
import android.util.Log
import com.google.ai.edge.litert.Accelerator
import com.google.ai.edge.litert.CompiledModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

data class Model(val name: String, val path: String, val size: Int)

// Nova estrutura de dados para o retorno duplo
data class SegmentationResult(val maskBytes: ByteArray, val maskArea: Int, val viewClass: String, val inferenceTime: Long )

class ImageSegmentationHelper(private val context: Context) {
    // Assumindo apenas o modelo novo conforme solicitado
    private val models = listOf(
        Model("unet", "unet.tflite", 16) 
    )
    private var currentModel: Model = models[0]
    private var segmenter: Segmenter? = null
    private val singleThreadDispatcher = Dispatchers.IO.limitedParallelism(1, "ModelDispatcher")

    fun getModelNames(): List<String> {
        return models.map { it.name }
    }

    suspend fun selectModel(name: String) {
        val model = models.find { it.name == name }
        if (model != null) {
            currentModel = model
            segmenter?.cleanup()
            initSegmenter()
        }
    }

    suspend fun initSegmenter() {
        withContext(singleThreadDispatcher) {
            val model = CompiledModel.create(
                context.assets,
                currentModel.path,
                CompiledModel.Options(Accelerator.GPU),
                null
            )
            segmenter = Segmenter(model)
        }
    }

    suspend fun segment(imageBytes: ByteArray): SegmentationResult? {
        return withContext(singleThreadDispatcher) {
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size) ?: return@withContext null
            segmenter?.segment(bitmap)
        }
    }

    fun cleanup() {
        segmenter?.cleanup()
        segmenter = null
    }

    private class Segmenter(private val model: CompiledModel) {
        private val inputBuffers = model.createInputBuffers()
        private val outputBuffers = model.createOutputBuffers()

        fun cleanup() {
            inputBuffers.forEach { it.close() }
            outputBuffers.forEach { it.close() }
            model.close()
        }

        fun segment(bitmap: Bitmap): SegmentationResult {
            val tag = "FeveInference"
            val totalStartTime = SystemClock.uptimeMillis()

            val width = bitmap.width
            val height = bitmap.height
            val numPixels = width * height

            // 2. Pré-processamento
            val preprocessStartTime = SystemClock.uptimeMillis()
            val inputFloatArray = normalizeToGrayscale(bitmap)
            Log.d(tag, "Tempo de pré-processamento: ${SystemClock.uptimeMillis() - preprocessStartTime} ms")

            // 3. Executar o modelo (INFERÊNCIA)
            inputBuffers[0].writeFloat(inputFloatArray)

            val inferenceStartTime = SystemClock.uptimeMillis()
            model.run(inputBuffers, outputBuffers)

            // Leitura dinâmica dos outputs para evitar erros de índice (0 ou 1)
            var maskFloatArray: FloatArray? = null
            var classFloatArray: FloatArray? = null

            for (buffer in outputBuffers) {
                val array = buffer.readFloat()
                if (array.size == numPixels) {
                    maskFloatArray = array // É o outputMask [1, 256, 256, 1]
                } else if (array.size == 1) {
                    classFloatArray = array // É o outputClass [1, 1]
                }
            }

            val inferenceTime = SystemClock.uptimeMillis() - inferenceStartTime
            Log.d(tag, "TEMPO DE INFERÊNCIA REAL: $inferenceTime ms")

            // 4. Pós-processamento
            val postprocessStartTime = SystemClock.uptimeMillis()
            
            // Processa a máscara
            val maskBytes = processMask(maskFloatArray!!, numPixels)
            
            // Processa a classe (Sigmoid: > 0.5 é uma classe, <= 0.5 é a outra)
            // IMPORTANTE: Ajuste qual é A2C e qual é A4C dependendo de como você treinou seus labels no Python!
            val classProb = classFloatArray!![0]
            val predictedClass = if (classProb > 0.5f) "A4C" else "A2C" 
            
            Log.d(tag, "Tempo de pós-processamento REAL: ${SystemClock.uptimeMillis() - postprocessStartTime} ms")
            Log.d(tag, "Classe predita: $predictedClass (Probabilidade: $classProb)")

            val totalTime = SystemClock.uptimeMillis() - totalStartTime
            Log.d(tag, "Tempo TOTAL: $totalTime ms")

            return SegmentationResult(maskBytes.maskBytes,maskBytes.area, predictedClass, totalTime)
        }

        private fun normalizeToGrayscale(image: Bitmap): FloatArray {
            val numPixels = image.width * image.height
            val pixelsIntArray = IntArray(numPixels)
            val outputFloatArray = FloatArray(numPixels)

            image.getPixels(pixelsIntArray, 0, image.width, 0, 0, image.width, image.height)

            for (i in 0 until numPixels) {
                val pixel = pixelsIntArray[i]
                val gray = Color.red(pixel)
                outputFloatArray[i] = gray / 255.0f
            }

            return outputFloatArray
        }

        private fun processMask(outputFloatArray: FloatArray, numPixels: Int): MaskData {
            var totalArea = 0
            val mask = ByteArray(numPixels * 4)
            var offset = 0

            for (i in 0 until numPixels) {
                if (outputFloatArray[i] > 0.5f) {
                    totalArea++

                    mask[offset] = 0.toByte()
                    mask[offset + 1] = 0.toByte()
                    mask[offset + 2] = 128.toByte()
                    mask[offset + 3] = 128.toByte()
                } else {

                    mask[offset] = 0.toByte()
                    mask[offset + 1] = 0.toByte()
                    mask[offset + 2] = 0.toByte()
                    mask[offset + 3] = 0.toByte()
                }
                offset += 4
            }

            return MaskData(mask, totalArea)
        }
    }
}