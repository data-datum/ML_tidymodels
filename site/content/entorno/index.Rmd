---
title: "Instalación de programas y librerías"  # Add a page title.
summary: "Lista de instalación"  # Add a page description.
date: "2020-01-01T00:00:00Z"  # Add today's date.
---

Gracias por inscribirte a este workshop, en el mismo trabajaremos con una versión reciente de R y Rstudio, por lo que, para aprovecharlo deberás tener una PC con lo siguiente instalado:

Instalación de R and RStudio

* Una versión reciente de R (>=3.6.3) disponible de manera gratuita para su descarga en CRAN.

* Una versión reciente de Rstudio Desktop (>= 1.3.959) disponible de manera gratuita para su descarga en Rstudio.

En ambos casos, ten en cuenta cuál es el Sistema Operativo que utilizas y la versión del mismo (32 o 64 bits) para descargar la versión correcta tanto de R como de Rstudio.

* Los paquetes que utilizaremos pueden instalarse, abriendo Rstudio y ejecutando las siguientes sentencias:

```{r eval=FALSE}
mis_paquetes <- c("tidyverse", "tidymodels","devtools", "kknn", "rpart", "rpart.plot", "rattle", "AmesHousing", "ranger", "partykit", "vip")

install.packages(mis_paquetes, repos = "http://cran.rstudio.com")
```


Para poder instalar de manera exitosa los paquetes, es necesario que estés conectado a Internet.

¿Cómo verifico que los paquetes se instalaron correctamente?

Para verificar que los paquetes se cargaron correctamente, por favor ejecutá las sentencias que están a continuación:

```{r eval=FALSE}
easypackages::libraries("tidyverse", "gapminder","babynames","survey","socviz","here","cowplot", 
                        "patchwork", "ggrepel","ggridges","ggforce", "gridExtra","extrafont",
                        "scales","wesanderson","viridis", "viridisLite","prismatic","fishualize",
                        "RColorBrewer", "ggtext","ggthemes","hrbrthemes","plotly","highcharter","GGally",
                        "sf","maps", "mapdata","mapproj","rnaturalearth","devtools")
```

