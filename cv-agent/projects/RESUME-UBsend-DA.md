# Projekterfaring

Start dato (måned/år): 11/2020
Slut dato (måned/år): 02/2021

## Kunde

Kundenavn: UBsend A/S
Projektnavn: UBsend

UBsend er en fragtbroker ejet af BestSeller-koncernen, der driver en række tøjbutikker både fysisk og online i flere lande. Platformen fungerer som et samlet integrationsspunkt, der forbinder online butikker med lokale fragtfirmaer på tværs af landegrænser. Dette gør det muligt for butikker at planlægge og styre fragt af pakker til mange forskellige lande gennem én samlet løsning, i stedet for at skulle integrere med hvert enkelt fragtfirma individuelt. Selvom UBsend er en del af BestSeller, blev platformen på det tidspunkt primært brugt af eksterne virksomheder, herunder en større tysk tøjbutik.

Kunderne havde brug for at sende pakker til hele Europa og fra flere forskellige lande, hvilket krævede integration med multiple last mile providers i hvert land. Platformens stabilitet var afgørende for at sikre, at kunderne kunne stole på at deres pakker blev leveret til tiden.

Projektet stod i en situation hvor udviklerstaben var gået fra 10+ medarbejdere ned til blot én tilbageværende udvikler efter et stort mandefald. Der var behov for hurtigt at få stabiliseret platformen og udbygget med nye integrationer for at kunne betjene kunder på tværs af flere europæiske markeder.

## Udviklerens rolle

Navn på rolle: Software Developer (Backend)

Jonas Nielsen arbejdede i et lille team bestående af fire udviklere og en Product Owner, hvor han trådte ind sammen med to andre nyansatte efter et stort mandefald. Den eneste tilbageværende udvikler fra det oprindelige team på 10+ havde ikke en formel lead-rolle, så Jonas arbejdede meget selvstændigt med stort ansvar for egen kodebase.

Jonas' primære opgave var at optimere og bygge nye microservices med ansvar for integrationer til eksterne partnere. De nye microservices blev bygget i Java, mens vedligeholdelse af eksisterende legacy-komponenter krævede C# og .NET. Hver microservice havde ansvar for integration til specifikke fragtfirmaer eller domæner, hvilket isolerede fejl og gjorde systemet mere robust.

En af Jonas' væsentligste præstationer var løsningen af et kritisk Out-of-Memory problem, som havde været uløst af den tidligere udvikler. Jonas analyserede kodebasen og identificerede årsagen til problemet, hvorefter han implementerede en løsning der reducerede memory-forbruget til 1/13.250 af det oprindelige niveau. Denne optimering sikrede platformens stabilitet og muliggjorde fortsat drift uden nedbrud.

Jonas tog ansvar for at udvikle to nye integrationer til eksterne fragtfirmaer fra bunden. Disse integrationer skulle håndtere forskellige dataformater og API'er, da hvert fragtfirma har deres egen måde at modtage og behandle forsendelsesdata på. Integrationerne udvidede platformens dækning til flere europæiske lande og gav kunderne flere muligheder for last mile levering.

Som resultat af Jonas' indsats blev platformens stabilitet sikret, og integrationerne udvidede UBsend's muligheder for at betjene kunder på tværs af flere europæiske markeder.

Teamet arbejdede med en arkitektur baseret på microservices, hvor forskellige services havde ansvar for specifikke domæner. Jonas bidrog til at holde arkitekturen simpel og vedligeholdelig trods den begrænsede bemanding.

## Kompetencer

- Java
- Microservices
- Kubernetes
- Docker
- MongoDB
- Microsoft SQL Server
- C#
- .NET
- REST
- Integration

