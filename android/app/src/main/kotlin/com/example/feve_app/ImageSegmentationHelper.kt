package com.example.feve_app



import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.SystemClock
import android.util.Log
import com.google.ai.edge.litert.Accelerator
import com.google.ai.edge.litert.CompiledModel
import java.nio.FloatBuffer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

data class Model(val name: String, val path: String, val size: Int)

class ImageSegmentationHelper(private val context: Context) {
    private val models = listOf(
        Model("unet_29_03_float32", "unet_29_03_float32.tflite", 32),
        Model("unet_30_03_float32", "unet_30_03_float32.tflite", 64),
        Model("unet_31_03_float32", "unet_31_03_float32.tflite", 16),
        Model("unet_01_04_float32", "unet_01_04_float32.tflite", 8)
    )
    private var currentModel: Model = models[1] // Default to unet_30_03_float32
    private var segmenter: Segmenter? = null
    private val singleThreadDispatcher = Dispatchers.IO.limitedParallelism(1, "ModelDispatcher")

    fun getModelNames(): List<String> {
        return models.map { it.name }
    }

    suspend fun selectModel(name: String) {
        val model = models.find { it.name == name }
        if (model != null) {
            currentModel = model
            // Reinitialize segmenter with new model
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

    suspend fun segment(imageBytes: ByteArray): ByteArray? {
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

        fun segment(bitmap: Bitmap): ByteArray {
            val tag = "FeveInference"
            val totalStartTime = SystemClock.uptimeMillis()

            val width = bitmap.width
            val height = bitmap.height

            // 2. Pré-processamento Otimizado
            val preprocessStartTime = SystemClock.uptimeMillis()
            val inputFloatArray = normalizeToGrayscale(bitmap)
            Log.d(tag, "Tempo de pré-processamento: ${SystemClock.uptimeMillis() - preprocessStartTime} ms")

            // 3. Executar o modelo (INFERÊNCIA)
            inputBuffers[0].writeFloat(inputFloatArray)

            val inferenceStartTime = SystemClock.uptimeMillis()
            model.run(inputBuffers, outputBuffers)

            // O PULO DO GATO: Lemos o float aqui. Isso força a CPU a esperar a GPU terminar.
            val outputFloatArray = outputBuffers[0].readFloat()

            val inferenceTime = SystemClock.uptimeMillis() - inferenceStartTime
            Log.d(tag, "TEMPO DE INFERÊNCIA REAL (Processamento GPU + Cópia de Memória): $inferenceTime ms")

            // 4. Pós-processamento: Apenas a lógica do seu processMask
            val postprocessStartTime = SystemClock.uptimeMillis()
            val maskBytes = processMask(outputFloatArray, width * height)
            Log.d(tag, "Tempo de pós-processamento REAL: ${SystemClock.uptimeMillis() - postprocessStartTime} ms")

            val totalTime = SystemClock.uptimeMillis() - totalStartTime
            Log.d(tag, "Tempo TOTAL (Pré + Inferência + Pós): $totalTime ms")

            return maskBytes
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

        private fun processMask(outputFloatArray: FloatArray, numPixels: Int): ByteArray {
            val mask = ByteArray(numPixels)
            for (i in 0 until numPixels) {
                // Assumindo que a saída do modelo é Sigmoid (probabilidades de 0 a 1).
                // Se a probabilidade for maior que 50%, marcamos como ventrículo (255), senão fundo (0).
                mask[i] = if (outputFloatArray[i] > 0.5f) 255.toByte() else 0.toByte()
            }
            return mask
        }
    }
}