<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/css/bootstrap.min.css" integrity="sha384-zCbKRCUGaJDkqS1kPbPd7TveP5iyJE0EjAuZQTgFLD2ylzuqKfdKlfG/eSrtxUkn" crossorigin="anonymous">
    <link rel="stylesheet" href="/DBProject2021/css/form.css">
    <link rel="stylesheet" href="/DBProject2021/css/base.css">
    <title>Base</title>
</head>
<body>

    <?php
        session_start();
        if(time() > $_SESSION['expire']) {
            session_unset();
            session_destroy();
            header('Location:/DBProject2021/landingPage/index.php');
        } 

        // Connection to db
        $pdo = new PDO('mysql:host=localhost;dbname=CONFVIRTUAL', $user = 'root', $pass = 'root');
        $pdo -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo -> exec('SET NAMES "utf8"');

        $query = ('SELECT * FROM CONFERENZA WHERE Svolgimento = "ATTIVA"');

        $res = $pdo -> prepare($query);
        $res -> execute();
        $conferenze = array(); 

        while($row = $res -> fetch()) {
            $conferenza = new stdClass();
            $conferenza -> acronimo = $row["Acronimo"];
            $conferenza -> nome = $row["Nome"];
            $conferenza -> annoEdizione = $row["AnnoEdizione"];
            array_push($conferenze, $conferenza);
        }
        
        $querySessions = ('SELECT * FROM SESSIONE');
        
        $res = $pdo -> prepare($querySessions);
        $res -> execute();
        $sessioni = array();

        while($row = $res -> fetch()) {
            $sessione = new stdClass();
            $sessione -> acronimoConferenza = $row["AcronimoConferenza"];
            $sessione -> titoloSessione = $row["Titolo"];
            $sessione -> numPresentazioni = $row["NumeroPresentazioni"];
            array_push($sessioni, $sessione);
        }

        $queryMessages = ('SELECT *
                            FROM REGISTRAZIONE AS R, SESSIONE AS S
                            WHERE R.AcronimoConferenza = S.AcronimoConferenza AND Username = :lab1');
        
        $res = $pdo -> prepare($queryMessages);
        $res -> bindValue(":lab1", $_SESSION['user']);
        $res -> execute();

        $sessionsPermitted = array();
        while($row = $res -> fetch()) {
            $sessione = new stdClass();
            $sessione -> acronimoConferenza = $row["AcronimoConferenza"];
            $sessione -> titoloSessione = $row["Titolo"];
            $sessione -> data = $row["Data"];
            $sessione -> oraInizio = $row["OraInizio"];
            $sessione -> oraFine = $row["OraFine"];
            array_push($sessionsPermitted, $sessione);
        }

    ?>
    
    <div class="wrapper">
        <nav id="sidebar" class="vh-100 bg-primary">
            <div class="sidebar-header">
                <a class="btn btn-primary" href="/DBProject2021/landingPage/index.php" role="button">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="currentColor" class="bi bi-house" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M2 13.5V7h1v6.5a.5.5 0 0 0 .5.5h9a.5.5 0 0 0 .5-.5V7h1v6.5a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 2 13.5zm11-11V6l-2-2V2.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5z"/>
                        <path fill-rule="evenodd" d="M7.293 1.5a1 1 0 0 1 1.414 0l6.647 6.646a.5.5 0 0 1-.708.708L8 2.207 1.354 8.854a.5.5 0 1 1-.708-.708L7.293 1.5z"/>
                    </svg>
                </a>
                <hr>
            </div>
            <ul class="list-unstyled components">
                <li> <a href="#" onclick="visualizeConferences()">Visualizza conferenze</a> </li>
                <li> <a href="#" onclick="registerToConference()">Registrati ad una conferenza</a> </li>
                <li> <a href="#" onclick="visualizeSessions()">Visualizza sessioni</a> </li>
                <li> <a href="#" onclick="insertMessage()">Inserisci messaggio</a> </li>
                <li> <a href="/DBProject2021/chat/chat.php" onclick="">Visualizza chat di sessione</a> </li>
                <li> <a href="#pageSubmenu" data-toggle="collapse" aria-expanded="false" class="dropdown-toggle">Favorites</a>
                    <ul class="collapse list-unstyled" id="pageSubmenu">
                        <li> <a href="#">New favorite</a> </li>
                        <li> <a href="#">My favorites</a> </li>
                    </ul>
                </li>
                
                <li> 
                    <?php
                        session_start();
                        
                        if (isset($_SESSION['userType']) && $_SESSION['userType'] == "ADMIN") {
                            print'  
                                    <a href="/DBProject2021/functionalities/admin.php" class="container me-4">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
                                            <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                                            <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
                                        </svg>
                                        Admin area
                                    </a';
                        
                        } elseif(isset($_SESSION['userType']) && $_SESSION['userType'] == "PRESENTER") {
                            print'
                                    <a href="/DBProject2021/functionalities/speaker_presenter.php" class="container me-4">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
                                            <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                                            <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
                                        </svg>
                                        Presenter area
                                    </a';
                        
                        } elseif(isset($_SESSION['userType']) && $_SESSION['userType'] == "SPEAKER") {
                            print'
                                    <a href="/DBProject2021/functionalities/speaker_presenter.php" class="container me-4">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" class="bi bi-person-circle" viewBox="0 0 16 16">
                                            <path d="M11 6a3 3 0 1 1-6 0 3 3 0 0 1 6 0z"/>
                                            <path fill-rule="evenodd" d="M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8zm8-7a7 7 0 0 0-5.468 11.37C3.242 11.226 4.805 10 8 10s4.757 1.225 5.468 2.37A7 7 0 0 0 8 1z"/>
                                        </svg>
                                        Speaker area
                                    </a';
                        }
                    ?>
                </li>
            </ul>
        </nav>

        <div class="content container-fluid">
            <nav class="navbar navbar-expand-lg navbar-light bg-light">
                 <button type="button" id="sidebarCollapse" class="btn navbar-toggler-icon"> </button> 
            </nav>
            
        <?php
            session_start();
            if (isset($_SESSION["opSuccesfull"])) {
        ?>
            
        <?php print'
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <strong>Ottimo!</strong> Operazione andata a buon fine!
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
              </div>
            ';
            unset($_SESSION["opSuccesfull"]);
        ?>
    
        <?php
            } elseif(isset($_SESSION["error"])) {
            unset($_SESSION["error"]);
        ?>
           <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <strong>Si è verificato un errore!</strong> Riprova controllando che i campi inseriti siano corretti.
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        <?php
            }
        ?>

            <div id="main-content" class="content-wrapper text-center">

            </div>            
            
        </div>
    </div>

    <!-- JAVASCRIPT -->
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    
    <script>
        
        const content = document.getElementById("main-content");
        const userName = <?php echo json_encode($_SESSION["user"]); ?>
        
        // Array di conferenze e sessioni presi tradotti da php
        var conferenze = <?php echo json_encode($conferenze); ?>;
        var sessioni = <?php echo json_encode($sessioni); ?>;
        var sessioniPermesse = <?php echo json_encode($sessionsPermitted); ?>;

        function visualizeConferences() {
            content.textContent = '';
            let div = document.createElement('div');
            div.classList.add('row');
            var cardContent = "";

            for(let i = 0; i < conferenze.length; i++) {
                acr = conferenze[i]["acronimo"];
                anno = conferenze[i]["annoEdizione"];
                title = conferenze[i]["nome"];
                cardContent += ` 
                    <div class="card" style="width: 18rem; margin: 5px 5px">
                        <div class="card-body">
                            <h5 class="card-title">${title}</h5>
                            <p class="card-text">Acronimo: ${acr} <br> Anno edizione: ${anno}</p>
                            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#${acr}">Register</button>
                        </div>
                    </div>

                    <div id="${acr}" class="modal fade">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="exampleModalLabel">Attenzione</h5>
                                    <button type="button" class="btn" data-dismiss="modal" aria-label="Close">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="currentColor" class="bi bi-x" viewBox="0 0 16 16">
                                            <path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
                                        </svg>
                                    </button>
                                </div>
                                <div class="modal-body">
                                    Sei sicuro di volerti registrare a ${title}? 
                                </div>
                                <div class="modal-footer">
                                    <form action="registerToConference.php" method="post" class="container">
                                        <div class="mb-3 form-group floating">
                                            <input type="hidden" class="form-control floating" name="username" value=${userName} readonly>
                                        </div>
                                        <div class="mb-3 form-group floating">
                                            <input type="hidden" class="form-control floating" name="acronimo" value=${acr} autocomplete="off">
                                        </div>
                                        <div class="mb-3 form-group floating">
                                            <input type="hidden" class="form-control floating" name="annoEdizione" value=${anno} autocomplete="off">
                                        </div>
                                        <div class="container text-center">
                                            <button type="submit" class="btn btn-primary">Register</button>
                                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                        </div>
                                    </form>                                    
                                </div>
                            </div>
                        </div>
                    </div>`;
            }
            
            div.innerHTML = cardContent;
            content.append(div);
        }

        function registerToConference() {
            content.textContent = '';
            content.innerHTML = `
            <div class="container-fluid text-center">
                <h2>Registrati</h2>
                <hr class="my-4">
                <form action="registerToConference.php" method="post" class="container my-5">
                    <div class="mb-3 form-group floating">
                        <input type="text" class="form-control floating" name="username" required value=${userName} readonly>
                        <label for="username">Username</label>          
                    </div>
                    <div class="mb-3 form-group floating">
                        <input type="text" class="form-control floating" name="acronimo" required autocomplete="off">
                        <label for="acronimo">Acronimo Conferenza</label> 
                    </div>
                    <div class="mb-3 form-group floating">
                        <input type="number" min="1900" max="2099" class="form-control floating" name="annoEdizione" required autocomplete="off">
                        <label for="annoEdizione">Anno</label>          
                    </div>
                    <div class="container text-center my-5">
                        <button type="submit" class="btn btn-primary">Register</button>
                    </div>
                </form>
            </div>
            `;
            
        }

        function visualizeSessions() {
            
            content.textContent = '';
            var dynamicContent = `                
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th scope="col">#</th>
                        <th scope="col">Conferenza</th>
                        <th scope="col">Titolo Sessione</th>
                        <th scope="col">Numero di Presentazioni</th>
                    </tr>
                </thead>
                <tbody>`;
            
            dynamicPresentations = [];
            for(let i = 0; i < sessioni.length; i++) {
                dynPres = `<table class="table table-striped">
                <thead>
                    <tr>
                        <th scope="col">Conferenza</th>
                        <th scope="col">Titolo Sessione</th>
                        <th scope="col">Numero di Presentazioni</th>
                    </tr>
                </thead>
                <tbody>`;
                dynPres += `<tr><td>sie he</td><td>ciao</td><td>ciao</td></tr>`
                dynPres += `</tbody></table>`;
                dynamicPresentations[i] = dynPres; 
            }
            console.log(dynamicPresentations);

            
            for(let i = 0; i < sessioni.length; i++) {
                acr = sessioni[i]["acronimoConferenza"];
                titleSession = sessioni[i]["titoloSessione"];
                numPresentazioni = sessioni[i]["numPresentazioni"];
                dynamicContent += `
                <tr>
                    <th scope="row">${i+1}</th>                    
                    <td>${acr}</td>
                    <td><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#${acr}${titleSession}">${titleSession}</button></td> 
                    </td>
                    <td>${numPresentazioni}</td>
                    
                    <div id="${acr}${titleSession}" class="modal fade">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="exampleModalLabel">Attenzione</h5>
                                    <button type="button" class="btn" data-dismiss="modal" aria-label="Close">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="currentColor" class="bi bi-x" viewBox="0 0 16 16">
                                            <path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
                                        </svg>
                                    </button>
                                </div>
                                <div class="modal-body">
                                ${acr}${titleSession}
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </tr>`;

                
            }
            
            dynamicContent += `</tbody></table>`;
            content.innerHTML = dynamicContent;
 
        }

        function insertMessage() {
            content.textContent = '';
            var dynamicContent = '';
            dynamicContent = `
            <div class="container text-center">
            <p> Chat a cui hai accesso <p> 
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th scope="col">Acronimo conferenza</th>
                            <th scope="col">Titolo sessione</th>
                            <th scope="col">Data</th>
                            <th scope="col">Ora inizio</th>
                            <th scope="col">Ora Fine</th>
                        </tr>
                    </thead>
                    <tbody> ` ;

            for(let i = 0; i < sessioniPermesse.length; i++) {
                acronimo = sessioniPermesse[i]["acronimoConferenza"];
                titoloSessione = sessioniPermesse[i]["titoloSessione"];
                oraInizio = sessioniPermesse[i]["oraInizio"];
                oraFine = sessioniPermesse[i]["oraFine"];
                data = sessioniPermesse[i]["data"];
                dynamicContent += `
                <tr>
                    <td>${acronimo}</td>
                    <td><form action="/DBProject2021/chat/chat.php" method="post" class="container">
                        <div class="mb-3 form-group floating">
                            <input type="hidden" class="form-control floating" name="acronimo" value=${acronimo} autocomplete="off">
                        </div>
                        <div class="mb-3 form-group floating">
                            <input type="hidden" class="form-control floating" name="titoloSessione" value=${titoloSessione} autocomplete="off">
                        </div>
                        <div class="container text-center">
                            <button class="btn btn-secondary" type="submit">${titoloSessione}</button></td>
                        </div>
                    </form> 
                    </td>   
                    <td>${data}</td>
                    <td>${oraInizio}</td>
                    <td>${oraFine}</td>
                </tr>`;
            }

            dynamicContent += `
                    </tbody>
                </table>
            </div>
            <p>I messaggi possono essere inseriti solo nell'orario indicato</p>`;

            content.innerHTML = dynamicContent;
        }

        // switch per il menu
        var radio = 0;
        document.getElementById("sidebarCollapse").addEventListener("click", () => {
            if(radio === 0) {
                document.getElementById("sidebar").classList.add("active");
                radio = 1;
            } else {
                document.getElementById("sidebar").classList.remove("active");
                radio = 0;
            }
        });

    </script>

    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js" integrity="sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.1/dist/js/bootstrap.min.js" integrity="sha384-VHvPCCyXqtD5DqJeNxl2dtTyhF78xXNXdkwX1CZeRusQfRKp+tA7hAShOK/B/fQ2" crossorigin="anonymous"></script>

</body>
</html>