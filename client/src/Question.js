import React, { Component } from "react";

export default class Question extends Component {
  // orderedAnswers = [];
  constructor(props) {
    super(props);
    this.state = {
      answered: false,
      correct: false
    }
  }

  render() {
    // let answers = [];
    // var correct_index = Math.floor(Math.random() * 4);
    // // if (orderedAnswers.length === 0) {
    // // console.log("going here");
    // for (var i = 0, j = 0; i < 4; i++) {
    //   if (i === correct_index) {
    //     answers.push(this.props.correct_answer)
    //   } else {
    //     answers.push(this.props.incorrect_answers[j]);
    //     j++;
    //   }
    // }
    // orderedAnswers = answers;
    // }
    return (
      <div style={{ fontWeight: "bold" }} key={"question" + this.props.question_number}>
        <br />
        {renderHTML(this.props.question)}
        {this.props.all_answers.map((a, i) => <Answer answered={this.state.answered} isCorrectAnswer={this.getCorrectIndex(a) === i} index={i} value={a} question_number={this.props.question_number}></Answer>)}
        {this.renderButtonOrStatus()}
      </div>
    );
  }

  getCorrectIndex(a) {
    for (var i = 0; i < this.props.all_answers.length; i++) {
      if (this.props.correct_answer === this.props.all_answers[i]) {
        console.log(i);
        return i;
      }
    }
    return 0;
  }

  renderButtonOrStatus() {
    if (this.state.answered) {
      if (this.state.correct) {
        return <div style={{ color: "green" }}>Correct!</div>
      }
      return <div style={{ color: "red" }}>Wrong!</div>
    }
    return (
      <div key={"submitbtndiv" + this.props.question_number}>
        <button onClick={() => { this.checkAnswer(this.props.question_number, this.props.correct_answer) }} type="button" key={"submitbtn" + this.props.question_number}>Submit</button>
      </div>
    );
  }

  checkAnswer(question_number, correct_answer) {
    for (var i = 0; i < 4; i++) {
      let checkboxid = "checkbox" + question_number + i;
      var checkbox = document.getElementById(checkboxid);
      if (checkbox.checked && checkbox.value === correct_answer) {
        this.setState({
          answered: true,
          correct: true
        });
        break;
      } else if (checkbox.checked) {
        this.setState({
          answered: true,
          correct: false
        });
        break;
      }
    }
  }
}

class Answer extends Component {
  getColor() {
    if (this.props.answered && this.props.isCorrectAnswer) {
      return "green";
    }
    return "auto";
  }

  render() {
    return (
      <div style={{ fontWeight: "normal" }} key={"answer" + this.props.question_number + this.props.index}>
        <input key={"input" + this.props.question_number + this.props.index} type="radio" id={"checkbox" + this.props.question_number + this.props.index} name={"checkboxset" + this.props.question_number} value={this.props.value} />
        <label key={"label" + this.props.question_number + this.props.index} for={"checkbox" + this.props.question_number + this.props.index} style={{ color: this.getColor() }}>{renderHTML(this.props.value)}</label>
      </div>
    );
  }
}

const renderHTML = (rawHTML) => React.createElement("span", { dangerouslySetInnerHTML: { __html: rawHTML } });
