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

Quality Street is a candy and snack producer with a huge presence in Europe, especially within the grandmother-segment.
The purpose of the project was to utilize data metrics from different factory production machines to ensure a more even distribution of the different chocolates in the big Quality Street tins. This was important for the customer, as they have received a lot of complaints regarding too many of the Strawberry Delight-chocolates.

## Udviklerens rolle

Navn på rolle: Software Developer (Backend) & assistant architect

John Doe worked in a team with a Senior Architect, two backenders, and one frontender (also from IT Minds). Every 2 weeks they met with a representative of Danish Grandmothers to advise them.
The first phase of the project was defining the architecture and talking to managers to understand the challenge at hand. John Doe took part in defining the initial architecture for the data platform along with the Senior Architect of the team.
The team ended up choosing a “data lake” setup where vast amounts of data from the different factory machines could be deposited.
The machines send their data in very different formats, groupings and frequencies to a central hub, where it is stored temporarily in the raw form. Several different functions then consume this data in order to streamline it to a universal format, before it is inserted into the data lake.
The team chose to keep the machines (and the IoT Edge device for each) dumb, in order to reduce the amount of software changes needed on on-premise-devices. For the central hub, it was decided to use an Azure event hub, and Azure Functions to parse and reformat the data.
John Doe built the majority of the Azure Functions, and helped with configuration of the Azure IoT event hub.
John Doe also helped create a website with a dashboard for management, building a GraphQL API for the data lake and assisting with some of the features for the page, which was written in React.
