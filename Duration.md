# Resumen del Problema de Duración de Notas

## El Problema

Al generar el archivo `test.mid`, las notas musicales sonaban excesivamente cortas, incluso después de configurar una `Duration` larga (ej. `whole`) en `Main.agda`. Cambiar el valor de la duración no parecía tener el efecto deseado.

## Proceso de Depuración

1.  **Análisis Inicial:** Se verificó que el valor de `Duration` (ej. `whole`) se pasaba correctamente desde `Main.agda` a la función `solveToMidi` en `SmtInterface.agda`.

2.  **Creación de Notas:** Dentro de `SmtInterface.agda`, se confirmó que la función `(map (tone dur))` usaba correctamente esta duración para crear los objetos de tipo `Note`. En este punto, los datos de las notas eran correctos.

3.  **Conversión a Eventos MIDI:** Se inspeccionó la función `notes→events` en `MidiEvent.agda`. Se comprobó que esta función también era correcta, ya que usaba la duración `d` de cada objeto `Note` para calcular los tiempos de inicio (`t`) y fin (`t + d`) de cada evento MIDI.

4.  **Descubrimiento Final:** El problema no estaba en la duración de las notas en sí, sino en el **tempo** de la pieza.

## Causa Raíz

En el archivo `SmtInterface.agda`, el tempo se calculaba de forma incorrecta, haciéndolo proporcional a la duración de la nota:

```agda
let tempo = 60 * dur -- 240 per note
```

Esto provocaba que al usar una duración larga como `whole` (valor 16), el tempo se disparara a `60 * 16 = 960` BPM (un tempo normal es ~120 BPM). La música se reproducía a una velocidad extrema, haciendo que todas las notas parecieran muy cortas.

## Solución

La solución fue desacoplar el tempo de la duración. Se modificó la línea anterior en `SmtInterface.agda` para usar un tempo fijo y razonable, como el `defaultTempo` (120) ya definido en el proyecto:

```agda
let tempo = defaultTempo
```

Este cambio permite que la duración de la nota (controlada desde `Main.agda`) y el tempo de la pieza sean independientes, solucionando el problema y otorgando el control esperado sobre la musicalidad del archivo MIDI resultante.
