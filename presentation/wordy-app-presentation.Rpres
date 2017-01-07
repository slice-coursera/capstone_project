Word Prediction based on Stupid Backoff N-gram Model
========================================================
author: B. Porter
date: 2016-01-02
autosize: true

The Wordy App for Coursera Data Science Specialization Capstone Project

Introduction
========================================================

- Goal: Develop an algorithm to predict the next word in a sentence and create a shiny app to demonstrate the algorithm.
- Algorithm: This app uses N-gram models with Stupid Backoff to smooth and predict on terms not seen in the highest level N-gram model.
- Shiny App: The shiny app is a simple UI that allows users to interact with the text prediction model and create next text based on the predictions

***
![Prediction Model Image](wordy-app-presentation-figure/shiny_app_screen.png)


Prediction Model
========================================================
- The prediction model is an N-gram model that uses Stupid Backoff for smoothing as described in [Large Language Models in Machine Translation](http://www.aclweb.org/anthology/D07-1090.pdf)
- Stupid backoff is a simple variation of other smoothing techniques that does not generate normalized probabilities but instead uses relative frequencies.
- The scores are for the backoff model are calculated using the following scheme:

$$
S(w|w_{i-k+1}^{i-1}) = \\ \left\{\begin{matrix}
\frac{f(w_{i-k+1}^i)}{w_{i-k+1}^{i-1}}, \mathbf{if} f(w_{i-k+1}^i) > 0 & \\ 
 & 
\end{matrix}\right.
$$

****
![Prediction Model Image](wordy-app-presentation-figure/quad_stupid_backoff_figure.jpg)

Quantitative Results
========================================================
- The model we have presented uses relative frequency and not normalized probabilities therefore Perplexity cannot be calculated.
- n-Gram Coverage is used instead to get an indication of quality improvements with increased training sizes

Wordy - The Shiny App
========================================================
- When the app starts there is a text input field that is pre-filled with text that you can easily replace
- Step 1: Input your text into the text field
- Step 2: Click the Predict! button to see the top possibilities from the prediction model
- Step 3: Click one of the top prediction options to see it automatically appended to the input text

***
![Prediction Model Image](wordy-app-presentation-figure/wordy_app_start.png)

Wordy - The Shiny App Continued
========================================================
![Prediction Model Image](wordy-app-presentation-figure/wordy_app_step3.png)

***
![Prediction Model Image](wordy-app-presentation-figure/wordy_app_final.png)
