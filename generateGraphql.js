const { graphqlToElm } = require('graphql-to-elm');
const request = require('request-promise');
const fs = require('fs-extra');

const creds = {
  email: 'test@mail.ru',
  password: '123456',
};

(async () => {
  try {
    const { data: { token } } = await request.post({
      uri: 'http://localhost:8080/login',
      headers: {
        Origin: 'http://localhost',
      },
      body: creds,
      json: true,
    });
    const file = await request.post({
      uri: 'http://localhost:8080/graphql-schema',
      headers: {
        Origin: 'http://localhost',
      },
      body: {
        token,
      },
      json: true,
    });
    await fs.createFile('./temp.graphql');
    await fs.writeFile('./temp.graphql', file);
    graphqlToElm({
      schema: "./temp.graphql",
      queries: [],
      src: "./src",
      dest: "./src-generated"
    });
  } catch (e) {
    console.error(e);
  }
})()

