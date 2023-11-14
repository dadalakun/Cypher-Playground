import { useState } from 'react';
import instance from './instance';
import styled from 'styled-components';
import Query from './Query';
import Console from './Console';

const Wrapper = styled.div`
    display: flex;
    align-items: center;
    flex-direction: column;
    height: 500px;
    padding: 1em;
    // border: 2px solid blue;
`;

function Body () {
    const [query, setQuery] = useState('');
    const [queryResult, setQueryResult] = useState('');
    const [isLoading, setIsLoading] = useState(false);

    const handleQuerySubmit = async () => {
      setIsLoading(true);
    
      const response = await sendQueryToValidationServer(query);
          
      if (response.status === 400) {
          // Validation error
          setQueryResult(response.data.message);
      } else if (response.status === 200) {
          // Set the console using the return messages from the Go server
          const formattedResult = JSON.stringify(response.data.data, null, 2);
          setQueryResult(formattedResult);
      } else {
          // Handle other unexpected status codes
          setQueryResult("Something went wrong...");
      }
      
      // Clear the text area after processing the query
      setQuery('');
      setIsLoading(false);
    };

    const sendQueryToValidationServer = async (query) => {
      try {
          // The validation server will firstly check the grammar of
          // the query (using parser and lexer). If the grammar passes
          // the validation, it will sent to the Go server.
          // So the response will be either the result of grammar checking
          // (if the grammar is invalid) or the result returned from the
          // Go server (where the cypher query is actually executed).
          const response = await instance.post('/check-query', { query });
          return response;
      } catch (error) {
          return error.response;
      }
    };

    return (
      <Wrapper>
        <Query 
            queryString={query} 
            setQueryString={setQuery}
            handleClick={handleQuerySubmit}
            disabled={isLoading}
        />
        <Console content={queryResult} />
      </Wrapper>
    );
};
  
  export default Body;