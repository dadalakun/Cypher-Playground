import styled from 'styled-components';
import Typography from '@mui/material/Typography';

const Wrapper = styled.section`
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100px;
    margin-bottom: 2em;
    // border: 2px solid purple;
`;

function Title () {
  return (
    <Wrapper>
      <Typography variant="h2">Cypher Playground</Typography>
    </Wrapper>
  );
};

export default Title;
