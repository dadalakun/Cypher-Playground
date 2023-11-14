import * as React from 'react'
import styled from 'styled-components';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';

const Row = styled.div`
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    height: 60px;
    margin: 0em 0em 1em 0em;
    // border: 2px solid green;
`;

const StyledTextField = styled(TextField)`
    width: 82%;
`;

const StyledButton = styled(Button)`
    width: 15%;
    height: 93%;
    // border: 2px solid blue;
`;

function Query ({queryString, setQueryString, handleClick, disabled}) {
    const handleChange = (e) => {
        setQueryString(e.target.value);
    };
    return(
        <Row>
            <StyledTextField
                placeholder="match (n) return n"
                value={queryString}
                onChange={handleChange}
                disabled={disabled}
            />
            <StyledButton
                variant="contained"
                disabled={!queryString}
                onClick={handleClick}
            >
                Query
            </StyledButton>
        </Row>
    );
};

export default Query;