# Projekterfaring

Start dato (måned/år): 10/2024
Slut dato (måned/år): 07/2026

Kompetencer:

- IoT
- Azure Functions
- Azure Event Hub
- Data Lake
- React
- GraphQL

## Kunde

Kundenavn: Quality Street
Projektnavn: Machine cloud connectivity

Quality Street er en slik- og snack-producent med en enorm tilstedeværelse i Europa, især inden for bedstemor-segmentet.

Formålet med projektet var at udnytte data metrics fra forskellige fabriksproduktionsmaskiner til at sikre en mere ensartet distribution af de forskellige chokolader i de store Quality Street bøtter. Dette var vigtigt for kunden, da de har modtaget en del klager vedrørende for mange af Strawberry Delight-chokoladerne.

## Udviklerens rolle

Navn på rolle: Software Developer (Backend) & assistant architect

John Doe arbejdede i et team med en Senior Architelt, to backendere og én frontender (også fra IT Minds). Hver 2. uge mødtes de med en repræsentant for Danish Grandmothers for at rådgive dem.

Den første fase af projektet bestod i at definere arkitekturen og tale med managers for at forstå den aktuelle udfordring. John Doe deltog i at definere den oprindelige arkitektur for dataplatformen sammen med teamets Senior Architekt.

Teamet endte med at vælge et "data lake"-setup, hvor enorme mængder data fra de forskellige fabriksmaskiner kunne deponeres. Maskinerne sender deres data i meget forskellige formater, grupperinger og frekvenser til en central hub, hvor det midlertidigt lagres i det rå format. Flere forskellige funktioner transformerer derefter disse data for at strømline dem til et universelt format, før de indsættes i data laken.

Teamet valgte at holde maskinerne (og IoT Edge-enheden for hver) "dum" for at reducere mængden af softwareændringer, der var nødvendige på on-premise-enheder. For den centrale hub blev det besluttet at bruge en Azure event hub og Azure Functions til at parse og reformatere dataene.

John Doe byggede størstedelen af disse Azure Functions og hjalp med konfigurationen af Azure IoT event hubben. John Doe hjalp også med at oprette en hjemmeside med et dashboard til management, hvor han byggede et GraphQL API til data laken og assisterede med nogle af funktionerne til siden, som var skrevet i React.
