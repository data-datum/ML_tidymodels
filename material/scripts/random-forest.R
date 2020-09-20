#decision trees palmer penguins
library(tidymodels)
library(palmerpenguins)

penguins <- palmerpenguins::penguins %>%
  drop_na() %>%
  select(-year,-sex, -island)


p_split <- penguins %>%
  initial_split(prop=0.75)

p_train <- training(p_split)
p_test  <- testing(p_split)

# para hacer validación cruzada
so_folds <- vfold_cv(p_train, strata = species)

set.seed(123)

vanilla_tree_spec <-
  decision_tree() %>% 
  set_engine("rpart") %>% 
  set_mode("classification")

#modelo vanilla sin tunning
vanilla_tree_spec %>% 
  fit_resamples(species ~ ., 
                resamples = so_folds) %>% 
  collect_metrics()

#tenemos 3 parametros para hacer tuneo
#tree_depth
#min_n
#cost_complexity


#tunning de hiperparametros
trees_spec <- decision_tree() %>% 
  set_engine("rpart") %>% 
  set_mode("classification") %>% 
  set_args(min_n = 20, cost_complexity = 0.1)

trees_spec %>%
  fit_resamples(species ~ ., 
                resamples = so_folds) %>% 
  collect_metrics()


# random forest

rf_spec <- rand_forest() %>% 
  set_engine("ranger") %>% 
  set_mode("classification")

set.seed(123)

rf_spec %>% 
  fit_resamples(species ~ ., 
                resamples = so_folds) %>% 
  collect_metrics()

------------------------------------------#random forest----------------------------------------------------
# con mtry = 3

rf3_spec <- rf_spec %>% 
  set_args(mtry = 3)

set.seed(123)

rf3_spec %>% 
  fit_resamples(species ~ ., 
                resamples = so_folds) %>% 
  collect_metrics()



# con mtry = 2

rf2_spec <- rf_spec %>% 
  set_args(mtry = 2)

set.seed(123)

rf2_spec %>% 
  fit_resamples(species ~ ., 
                resamples = so_folds) %>% 
  collect_metrics()



# con mtry = 4

rf4_spec <- rf_spec %>% 
  set_args(mtry = 4)

set.seed(123)

rf4_spec %>% 
  fit_resamples(species ~ ., 
                resamples = so_folds) %>% 
  collect_metrics()

----------------------------------#random forest tuneo automatico-------------------------

p_recipe <- training(p_split) %>%
  recipe(species~.) %>%
  step_corr(all_predictors()) %>%
  step_center(all_predictors(), -all_outcomes()) %>%
  step_scale(all_predictors(), -all_outcomes()) %>%
  prep()


tune_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) %>%
  set_mode("classification") %>%
  set_engine("ranger")


tune_wf <- workflow() %>%
  add_recipe(p_recipe) %>%
  add_model(tune_spec)

set.seed(234)
trees_folds <- vfold_cv(p_train, strata = species)

doParallel::registerDoParallel()

set.seed(345)
tune_res <- tune_grid(
  tune_wf,
  resamples = trees_folds,
  grid = 20
)

tune_res


#veamos graficamente el tuneo de estos hiperparámetros
#esto para tener idea los rangos de variación para hacer un tuneo más fino
tune_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  select(mean, min_n, mtry) %>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "AUC")


#seleccionamos el mejor modelo

best_auc <- select_best(tune_res, "roc_auc")

final_rf <- finalize_model(
  tune_spec,
  best_auc
)

final_rf

#importancia de las variables
library(vip)
final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(species ~ .,
      data = juice(p_recipe)) %>%
  vip(geom = "point")


final_wf <- workflow() %>%
  add_recipe(p_recipe) %>%
  add_model(final_rf)

final_res <- final_wf %>%
  last_fit(p_split)

final_res %>%
  collect_metrics()

--------------------------------#aca finaliza el modelo----------------------------------



#tuneando con un grid
rf_grid <- grid_regular(
  mtry(range = c(10, 20)),
  min_n(range = c(1, 4)),
  levels = 2
)

rf_grid


set.seed(123)
regular_res <- tune_grid(
  tune_wf,
  resamples = trees_folds,
  grid = rf_grid
)

regular_res



regular_res %>%
  collect_metrics() %>%
  filter(.metric == "roc_auc") %>%
  mutate(min_n = factor(min_n)) %>%
  ggplot(aes(mtry, mean, color = min_n)) +
  geom_line(alpha = 0.5, size = 1.5) +
  geom_point() +
  labs(y = "AUC")


#veamos cuantas muestras quedan en cada grupo
p_split  


# preprocesamiento

p_recipe <- training(p_split) %>%
  recipe(species~.) %>%
  step_corr(all_predictors()) %>%
  step_center(all_predictors(), -all_outcomes()) %>%
  step_scale(all_predictors(), -all_outcomes()) %>%
  prep()

#modelo
decision_tree() %>% 
  set_engine("rpart") %>% 
  set_mode("classification")%>%
  set_args(tree_depth = 30, min_n = 20, cost_complexity = .01)

# es lo mismo que escribir 
decision_tree(tree_depth = 30, min_n = 20, cost_complexity = .01) %>% 
  set_engine("rpart") %>% 
  set_mode("classification")


#workflows

p_wf <- workflow() %>% 
  add_model(decision_tree) %>% 
  add_recipe(p_recipe)

p_wf%>%
  fit_split(split = p_train) %>% 
  collect_metrics()



#p_train <- juice(p_recipe)

#p_test <- p_recipe %>%
#bake(testing(p_split))