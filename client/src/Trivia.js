import React, { Component } from "react";
import Question from "./Question";

export default class Trivia extends Component {
  render() {

    return (
      <div style={{ width: "100%", textAlign: "center" }}>
        <div style={{
          width: "50%", textAlign: "center",
          margin: "0 auto"
        }}>
          {this.props.questions.map((q, i) => <Question question={q.question} correct_answer={q.correct_answer} all_answers={this.getAllAnswers(q)} question_number={i} />)}
        </div>
        <br />
        <button onClick={() => {
          window.location.reload();

        }} type="button" key={"refreshbtn"}>Refresh Questions!</button>
      </div>
    );
  }
  getAllAnswers(q) {

    let answers = [];
    var correct_index = Math.floor(Math.random() * 4);
    for (var i = 0, j = 0; i < 4; i++) {
      if (i === correct_index) {
        answers.push(q.correct_answer)
      } else {
        answers.push(q.incorrect_answers[j]);
        j++;
      }
    }
    return answers;
  }
}

