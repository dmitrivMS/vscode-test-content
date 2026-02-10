# Linear regression analysis on the mtcars dataset

library(ggplot2)

data(mtcars)

# Fit model: mpg predicted by weight and horsepower
model <- lm(mpg ~ wt + hp, data = mtcars)
summary(model)

# Diagnostic plots
par(mfrow = c(2, 2))
plot(model)

# Prediction for a new car
new_car <- data.frame(wt = 3.0, hp = 150)
predicted_mpg <- predict(model, newdata = new_car, interval = "confidence")
cat("Predicted MPG:", round(predicted_mpg[1], 2), "\n")

# Scatter plot with regression line
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point(aes(color = factor(cyl)), size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "steelblue") +
  labs(title = "MPG vs Weight", x = "Weight (1000 lbs)", y = "Miles per Gallon") +
  theme_minimal()
