# Projekterfaring

Start dato (måned/år): 10/2024
Slut dato (måned/år): 08/2026

## Kunde

Kundenavn: Bunker Holding
Projektnavn: AuctionConnect

Bunker Holding er verdens største bunkeringsselskab og leverer skibsbrændstof til skibe over hele kloden. Traditionelt foregår meget af handlen over telefonopkald og WhatsApp med en broker som mellemmand mellem købere og leverandører.

AuctionConnect er en online auktionsplatform udviklet til at digitalisere og effektivisere bunkers-handel. Platformen bruges både af Bunker Holdings egne firmaer og af konkurrenter til hurtigere og mere effektivt at afholde auktioner, så køberne kan opnå de lavest mulige priser. Platformen muliggør realtidsopdateringer og live budgivning, hvilket gør processen hurtigere og mere kompetitiv.

Som resultat af AuctionConnect har platformen bidraget til salg af mere end 1 million MT (metric tons) brændstof om året. Brugere ser konsekvent priser, der er lavere end dagsindekset, og i løbet af det sidste halve år har der været en fordobling i antallet af månedlige auktioner. Platformen har typisk 10-15 købere som afholder auktioner med op til 40 samtidige brugere logget ind.

## Udviklerens rolle

Navn på rolle: Feature Lead & Senior Software Developer

Jonas Nielsen arbejdede oprindeligt som Feature Lead i et team bestående af 5 konsulenter fra IT Minds samt en UX'er fra et søsterselskab. I takt med projektets vækst har teamet udviklet sig betydeligt og inkluderer i dag en Product Manager, en CTO, en Engineering Manager samt 10-15 udviklere i Portugal. Jonas' rolle udviklede sig undervejs til mere at ligne en Senior Software Developer rolle.

Jonas tog ansvaret for udviklingen af en ny Contract Management feature, der håndterer langsigtede kontrakter for tankning af specifikke brændstoftyper i samme havn til en fast pris. Featuren var en strategisk prioritet for Bunker Holding, da den muliggør styring af månedlige volumener og automatiserer kommunikationen mellem rederi og leverandør, hvilket reducerer manuel opfølgning og sikrer mere forudsigelige indtægtsstrømme. Jonas arbejdede primært med backend-udvikling, men har rørt alle dele af systemet i løbet af projektet.

En central del af Jonas' arbejde var ansvaret for migrationen fra Elixir/Phoenix/LiveView til C#/.NET og React med SignalR. Jonas og teamet valgte at gribe migrationen an med et strangler pattern for at minimere risiko: Først blev LiveView-sider ikke-relateret til live auktioner overtaget af React med REST-endpoints. Derefter blev ansvar gradvist flyttet til .NET. Jonas designede et adapter/repository pattern til masterdata, så auktionsmotoren fortsat kunne tilgå firmaer, havne, brændstoftyper og skibe uden afbrydelser. På .NET-siden implementerede Jonas en wrapper-service, der kalder Elixir-endpoints for at hente auktionstilstand og udføre muterende handlinger, hvilket sikrede kontinuitet under migrationen.

Platformen benytter event sourcing og CQRS, hvilket giver automatisk auditing af alle handlinger i en auktion - en væsentlig fordel i den regulerede bunkeringsbranche hvor compliance og sporbarhed er kritisk for at opfylde branchens krav. Jonas sikrede at realtidsopdateringerne fra den oprindelige LiveView-arkitektur blev bevaret i den nye SignalR-baserede løsning, så brugere fortsat kunne følge med i live budgivning uden forsinkelser.

## Kompetencer

- C#
- .NET
- React
- SignalR
- Event Sourcing
- CQRS
- Elixir
- Azure
