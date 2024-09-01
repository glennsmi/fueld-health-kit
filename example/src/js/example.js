import { fueldHK } from 'fueld-hk';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    fueldHK.echo({ value: inputValue })
}
