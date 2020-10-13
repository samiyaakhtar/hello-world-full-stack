import React, { Component } from "react";
import logo from "./logo.svg";
import "./App.css";
import Trivia from "./Trivia";

const backendURL = process.env.REACT_APP_BACKEND_URL ? process.env.REACT_APP_BACKEND_URL : window.ENV.REACT_APP_BACKEND_URL;

class App extends Component {
    constructor(props) {
        super(props);
        this.state = { questions: [] };
    }

    callAPI() {
        console.log(backendURL);
        fetch(backendURL + "/trivia")
            .then(res => res.text())
            .then(res => {
                let questions = JSON.parse(res);
                this.setState({ questions: questions });
            })
            .catch(err => err);
    }

    componentDidMount() {
        this.callAPI();
    }

    render() {
        return (
            <div className="App">
                <header className="App-header">
                    <img src={logo} className="App-logo" alt="logo" />
                    <h1 className="App-title">Welcome to Simple Trivia</h1>
                </header>
                {/* <p className="App-intro">{this.state.apiResponse}</p> */}
                <Trivia questions={this.state.questions} />
            </div>
        );
    }
}

export default App;
