import Title from './Title';
import Body from './Body';
import styled from 'styled-components';
import Paper from '@mui/material/Paper';

const Wrapper = styled.div`
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    // border: 2px solid blue;
`;

const StyledPaper = styled(Paper)`
    width: 800px;
    height: 700px;
    padding: 2em;
    // border: 2px solid red;
`;

function App() {
  return (
    <Wrapper>
      <StyledPaper elevation={3}>
        <Title />
        <Body />
      </StyledPaper>
    </Wrapper>
  );
}

export default App;
