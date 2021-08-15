# Indice

- [Descrizione](#descrizione)
- [Impostazioni avanzate](#impostazioni-avanzate)
- [Librerie](#librerie)
- [Testato](#testato)
- [Download](#download)
- [Interfaccia utente](#interfaccia-utente)
- [Licenza](#licenza)

</br>

# Descrizione

Applicazione che permette, tramite un'interfaccia utente, di salvare e caricare la mappatura di tasti e combinazioni (fino a 3 tasti) abbinati a dei gesti predefiniti eseguiti con le mani attraverso l'utilizzo di un leap motion controller.

Il leap motion controller rileva e tiene traccia di mani, dita e strumenti simili a dita. Il dispositivo ha una porta ravvicinata con alta precisione e frequenza dei fotogrammi di tracciamento.

Il software Leap analizza gli oggetti osservati nel campo visivo del dispositivo. Riconosce le mani, le dita e gli strumenti, segnalando sia le posizioni discrete che il movimento. Il campo visivo di Leap è una piramide invertita centrata sul dispositivo. La portata effettiva del Leap si estende da circa 25 a 600 millimetri sopra il dispositivo.

</br>

# Impostazioni avanzate

Descrizione impostazioni avanzate:

- swipe delay: indica il delay in secondi tra uno swipe e un altro
- circle radius: indica il raggio minimo del cerchio da effettuare con un dito
- sensitivity x: indica il moltiplicatore della sensibilità delle ascisse
- sensitivity y: indica il moltiplicatore della sensibilità delle ordinate
- hand: indica se la mano da tracciare deve essere la destra o la sinistra
- display width: indica la larghezza in pixel del display
- display height: indica l'altezza in pixel del display

</br>

# Librerie

Ho utilizzato le seguenti librerie:

- [Leap motion for Processing](https://github.com/nok/leap-motion-processing)
- [Leap motion for Python](https://developer-archive.leapmotion.com/documentation/python/devguide/Sample_Tutorial.html?proglang=python)
- [ControlP5](https://github.com/sojamo/controlp5)
- [Winput](https://github.com/Zuzu-Typ/winput)
- [Mouse](https://github.com/boppreh/mouse)

Per installare le librerie su Processing è possibile accedere al Contribution Manager:

- Leap Motion
  
    ```code
    (Sketch > Import library ... > Add library ... > Filter: "Leap Motion").
    ```  

- ControlP5
  
    ```code
    (Sketch > Import library ... > Add library ... > Filter: "ControlP5").
    ```

Per installare le librerie su Python:

- Leap Motion

    1. Una volta installato l'SDK per leap motion all'interno questo percorso sono contenute le dll per la libreria Leap
  
        ```code
        LeapDeveloperKit_3.2.1+45911_win -> LeapSDK -> lib
        ```

    2. Una volta scelte le dll in base al proprio sistema operativo, creare una cartella lib all'interno del progetto, con all'interno una cartella Leap e incollare le dll

    3. Nel codice prima di importare la cartella Leap importare la libreria sys e inserire la seguente linea di codice:

        ```code
        sys.path.insert(0, "lib/leap")

        import Leap
        ```

- Winput

    Aprire il prompt dei comandi, spostarsi nella cartella in cui è installato python (se si utilizza la versione 2.7 all'interno della cartella Scripts) e digitare il comando:

    ```code
    pip install winput
    ```

- Mouse

    Aprire il prompt dei comandi, spostarsi nella cartella in cui è installato python (se si utilizza la versione 2.7 all'interno della cartella Scripts) e digitare il comando:

    ```code
    pip install mouse
    ```

</br>

# Testato

System:

- Windows (Windows 10)
- OSX (non testato ancora)
- Linux (non testato ancora)

Processing version:

- 3.5.4

Python version:

- 2.7.18

Leap Motion Software version:

- 3.2.1+45911
  
</br>

# Download

- [Leap Motion for Processing v3.2.1](https://developer.leapmotion.com/releases/leap-motion-orion-321)

- [Processing v3.5.4](https://processing.org/download/)

- [Python v2.7.18](https://www.python.org/downloads/)

</br>

# Interfaccia utente

![](https://gitlab.com/fablabcfv/stage_pcto/its_kennedy_21/alessandrini-luca/leapmotion/-/raw/main/img/UI.PNG)

</br>

# Licenza

[MIT](https://choosealicense.com/licenses/mit/)