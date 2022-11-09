import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={"data:image/jpeg;base64,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"} className="App-logo" alt="logo" />
        <p>
          VIRTUAL MACHINE 1
        </p>
        <p>
          Hello I'm VM 1  
        </p>
        <p>
          DevOps Project Labs Demo 1
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React, click here
        </a>
      </header>
    </div>
  );
}

export default App;