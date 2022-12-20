import {
  Table,
  Thead,
  Tr,
  Th,
  Td,
  Tbody,
  TableContainer,
  Input,
  Button,
} from '@chakra-ui/react';
import Head from 'next/head';
import Image from 'next/image';

export default function Home() {
  return (
    <>
      <div>
        <h1 className="text-xl font-bold text-center">
          {' '}
          Blockchain Voting Election{' '}
        </h1>
        <hr />
        <br />
        <TableContainer>
          <Table variant="simple">
            <Thead>
              <Tr>
                <Th>Candidates</Th>
                <Th>Total Votes</Th>
              </Tr>
            </Thead>
            <Tbody>
              <Tr>
                <Td>Candidate 1</Td>
                <Td>Vote</Td>
              </Tr>
              <Tr>
                <Td>Candidate 2</Td>
                <Td>Vote</Td>
              </Tr>
            </Tbody>
          </Table>
        </TableContainer>
      </div>
      <Input type="text" htmlSize={4} width="auto" />
      <Button href="#" colorScheme="blue">
        {' '}
        Vote
      </Button>
    </>
  );
}
