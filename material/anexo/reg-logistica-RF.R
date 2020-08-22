#script de R 
#fuente: https://juliasilge.com/blog/palmer-penguins/

library(tidyverse)
library(palmerpenguins)

penguins_df<-penguins %>%
  filter(!is.na(sex))%>%
  select(-year, -island)

library(tidymodels)
library(ranger)
set.seed(123)
penguin_split<-initial_split(penguins_df, strata=sex)
penguin_train<-training(penguin_split)
penguin_test<-testing(penguin_split)

#boostrap resamples
penguin_boot<-bootstraps(penguin_train)
penguin_boot
#regresion logistica
glm_spec <- logistic_reg() %>%
  set_engine("glm")

glm_spec

#random forest
rf_spec<-rand_forest()%>%
  set_mode("classification")%>%
  set_engine("ranger")

rf_spec
#workflow para modelos
penguin_workf<-workflow()%>%
  add_formula(sex~.)
penguin_workf

#fit del modelo logistico
glm_fit<-penguin_workf%>%
  add_model(glm_spec)%>%
  fit_resamples(
    resamples=penguin_boot, 
    control=control_resamples(save_pred=TRUE)
  )

glm_results$.metrics #para ver las metricas de los resultados en cada split

#fit del modelo random forest
rf_fit<-penguin_workf%>%
  add_model(rf_spec)%>%
  fit_resamples(
    resamples=penguin_boot,
    control=control_resamples(save_pred=TRUE)
  )

rf_fit
rf_fit$metrics
#roc curve y accuracy
rf_fit %>%
  collect_metrics()
glm_fit %>%
  collect_metrics()
#matriz de confusion
glm_fit %>%
  conf_mat_resampled()
rf_fit %>%
  conf_mat_resampled()

#regresion logistica CURVA ROC
glm_fit %>%
  collect_predictions() %>%
  group_by(id) %>%
  roc_curve(sex, .pred_female) %>%
  ggplot(aes(1 - specificity, sensitivity, color = id)) +
  geom_abline(lty = 2, color = "gray80", size = 1.5) +
  geom_path(show.legend = FALSE, alpha = 0.6, size = 1.2) +
  coord_equal()

#random forest CURVA ROC
rf_fit %>%
  collect_predictions() %>%
  group_by(id) %>%
  roc_curve(sex, .pred_female) %>%
  ggplot(aes(1 - specificity, sensitivity, color = id)) +
  geom_abline(lty = 2, color = "gray80", size = 1.5) +
  geom_path(show.legend = FALSE, alpha = 0.6, size = 1.2) +
  coord_equal()

penguin_final <- penguin_workf %>%
  add_model(glm_spec) %>%
  last_fit(penguin_split)

penguin_final

collect_metrics(penguin_final)

collect_predictions(penguin_final) %>%
  conf_mat(sex, .pred_class)

install.packages("vip")
library(vip)

    