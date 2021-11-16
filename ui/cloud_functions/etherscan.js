const axios = require("axios");
const jsdom = require("jsdom");

/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.main = async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  let address = req.query.address || req.body.address || '0x0000000000000000000000000000000000000000';

  const holders = [];
  const result = await axios.get(
    `https://mumbai.polygonscan.com/token/generic-tokenholders2?m=normal&a=${address}&s=1000000000000000000000000`
  );

  const dom = new jsdom.JSDOM(result.data);
  const lines = dom.window.document.querySelectorAll("table tbody tr");
  lines.forEach((line) => {
    const cell = line.querySelectorAll("td");
    const holder = {
      rank: cell[0].textContent.trim(),
      address: cell[1].textContent.trim(),
      quantity: cell[2].textContent.trim(),
      percentage: cell[3].textContent.trim(),
      type: cell[1].querySelector("i") ? "contract" : "EOA",
    };
    holders.push(holder);
  });

  res.status(200).send(holders);
};