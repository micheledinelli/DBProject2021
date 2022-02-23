DROP DATABASE IF EXISTS CONFVIRTUAL;
CREATE DATABASE CONFVIRTUAL;
USE CONFVIRTUAL;

CREATE TABLE CONFERENZA(
	Nome VARCHAR(30),
    Acronimo VARCHAR(30),
	AnnoEdizione INT,
    Logo BLOB,
    Svolgimento ENUM("ATTIVA","COMPLETATA") DEFAULT "ATTIVA",
    TotaleSponsorizzazioni INT DEFAULT 0,
    PRIMARY KEY(Acronimo, AnnoEdizione)
) ENGINE="INNODB";

CREATE TABLE SPONSOR(
	Nome VARCHAR(30),
    Logo BLOB,
    PRIMARY KEY(Nome)
) ENGINE="INNODB";

CREATE TABLE SPONSORIZZAZIONE(
	AcronimoConferenza VARCHAR(30),
    AnnoEdizione INT,
    NomeSponsor VARCHAR(30),
    Importo DOUBLE,
    PRIMARY KEY(AcronimoConferenza, AnnoEdizione, NomeSponsor),
    FOREIGN KEY(AcronimoConferenza, AnnoEdizione) REFERENCES CONFERENZA(Acronimo, AnnoEdizione) ON DELETE CASCADE,
    FOREIGN KEY (NomeSponsor) REFERENCES SPONSOR(Nome) ON DELETE CASCADE
) ENGINE="INNODB";

CREATE TABLE UTENTE(
	Username VARCHAR(30),
    Password VARCHAR(30),
    Nome VARCHAR(25),
    Cognome VARCHAR(25),
    DataNascita DATE,
    Luogo VARCHAR(30),
    Tipologia ENUM("BASE","ADMIN","SPEAKER","PRESENTER") DEFAULT "BASE",
    PRIMARY KEY(Username)
) ENGINE="INNODB";

CREATE TABLE REGISTRAZIONE(
	Username VARCHAR(30),
    AcronimoConferenza VARCHAR(10),
    AnnoEdizione INT,
    PRIMARY KEY(Username, AcronimoConferenza, AnnoEdizione),
    FOREIGN KEY(AcronimoConferenza, AnnoEdizione) REFERENCES CONFERENZA(Acronimo, AnnoEdizione) ON DELETE CASCADE,
    FOREIGN KEY (Username) REFERENCES UTENTE(Username) ON DELETE CASCADE
) ENGINE="INNODB";

CREATE TABLE UNIVERSITA(
	NomeUniversità VARCHAR(30),
	NomeDipartimento VARCHAR(30),
    PRIMARY KEY(NomeUniversità)
)ENGINE="INNODB";

CREATE TABLE ADMIN(
    Username VARCHAR(30),
    PRIMARY KEY (Username),
    FOREIGN KEY (Username) REFERENCES UTENTE(Username) ON DELETE CASCADE 
) ENGINE="INNODB";

CREATE TABLE PRESENTER(
    Username VARCHAR(30),
    CurriculumVitae VARCHAR(30),
    Foto BLOB,
    NomeUniversità VARCHAR(30),
    PRIMARY KEY (Username),
    FOREIGN KEY (Username) REFERENCES UTENTE(Username),
    FOREIGN KEY(NomeUniversità) REFERENCES UNIVERSITA(NomeUniversità)
) ENGINE="INNODB";

CREATE TABLE SPEAKER(
    Username VARCHAR(30),
    CurriculumVitae VARCHAR(30),
    Foto BLOB,
    NomeUniversità VARCHAR(30), 
    PRIMARY KEY (Username),
    FOREIGN KEY (Username) REFERENCES UTENTE(Username),
	FOREIGN KEY(NomeUniversità) REFERENCES UNIVERSITA(NomeUniversità)
) ENGINE="INNODB";

CREATE TABLE CREAZIONE(
    UsernameAdmin VARCHAR(30),
    AcronimoConferenza VARCHAR(10),
    AnnoEdizione INT,
    PRIMARY KEY (UsernameAdmin, AcronimoConferenza, AnnoEdizione),
    FOREIGN KEY (UsernameAdmin) REFERENCES ADMIN(Username),
    FOREIGN KEY (AcronimoConferenza, AnnoEdizione) REFERENCES CONFERENZA(Acronimo, AnnoEdizione)
) ENGINE="INNODB";

CREATE TABLE DATASVOLGIMENTO(
    AcronimoConferenza VARCHAR(30),
    AnnoEdizione INT,
    Data DATE,
    PRIMARY KEY (AcronimoConferenza, AnnoEdizione, Data),
    FOREIGN KEY (AcronimoConferenza, AnnoEdizione) REFERENCES CONFERENZA(Acronimo, AnnoEdizione) ON DELETE CASCADE
) ENGINE="INNODB";

CREATE TABLE SESSIONE(
    AcronimoConferenza VARCHAR(30),
    Anno INT,
    Data DATE,
    Codice INT AUTO_INCREMENT,
    Titolo VARCHAR(100),
    NumeroPresentazioni INT DEFAULT 0,
    OraInizio TIME,
    OraFine TIME, 
    Link VARCHAR(50),
    PRIMARY KEY (Codice),
	FOREIGN KEY (AcronimoConferenza, Anno, Data) REFERENCES PROGRAMMAGIORNALIERO(AcronimoConferenza, AnnoEdizione, Data) ON DELETE CASCADE
) ENGINE="INNODB";

CREATE TABLE PRESENTAZIONE(
    Codice INT,
	CodiceSessione INT,
    OraInizio TIME,
    OraFine TIME,
    NumeroSequenza INT,
    Tipologia ENUM("ARTICOLO", "TUTORIAL"),
    PRIMARY KEY (Codice),
    FOREIGN KEY (CodiceSessione) REFERENCES SESSIONE(Codice) ON DELETE CASCADE
)ENGINE="INNODB";

CREATE TABLE P_ARTICOLO(
	CodicePresentazione INT,
    Titolo VARCHAR(30),
    NumeroPagine INT,
    FilePDF BLOB,
    StatoSvolgimento ENUM ("COPERTO", "NON COPERTO") DEFAULT "NON COPERTO",
    UsernamePresenter VARCHAR(30),
    PRIMARY KEY (CodicePresentazione),
    FOREIGN KEY(CodicePresentazione) REFERENCES PRESENTAZIONE(Codice) ON DELETE CASCADE,
    FOREIGN KEY(UsernamePresenter) REFERENCES PRESENTER(Username) ON DELETE CASCADE
)ENGINE="INNODB";

CREATE TABLE P_TUTORIAL(
	CodicePresentazione INT,
	Titolo VARCHAR(30),
	Abstract VARCHAR(500),
	PRIMARY KEY (CodicePresentazione),
	FOREIGN KEY(CodicePresentazione) REFERENCES PRESENTAZIONE(Codice)
)ENGINE="INNODB";

CREATE TABLE AUTORE(
	Nome VARCHAR(25),
	Cognome VARCHAR(25),
	PRIMARY KEY(Nome, Cognome)
)ENGINE="INNODB";

CREATE TABLE SCRITTURA(
	NomeAutore VARCHAR(25),
	CognomeAutore VARCHAR(25),
	CodiceArticolo INT,
	PRIMARY KEY(NomeAutore, CognomeAutore, CodiceArticolo),
	FOREIGN KEY(CodiceArticolo) REFERENCES P_ARTICOLO(CodicePresentazione),
	FOREIGN KEY(NomeAutore, CognomeAutore) REFERENCES AUTORE(Nome, Cognome)
)ENGINE="INNODB";

CREATE TABLE KEYWORD(
	Parola VARCHAR(20),
	CodiceArticolo INT,
	PRIMARY KEY(Parola, CodiceArticolo),
	FOREIGN KEY (CodiceArticolo) REFERENCES P_ARTICOLO(CodicePresentazione)
)ENGINE="INNODB";

CREATE TABLE VALUTAZIONE(
	UsernameAdmin VARCHAR(30),
	Voto INT,
	Note VARCHAR(50),
	CodicePresentazione INT,
	PRIMARY KEY(UsernameAdmin, CodicePresentazione),
	FOREIGN KEY(UsernameAdmin) REFERENCES ADMIN(Username),
	FOREIGN KEY(CodicePresentazione) REFERENCES PRESENTAZIONE(Codice)
)ENGINE="INNODB";

CREATE TABLE RISORSA(
	UsernameSpeaker VARCHAR(30),
    Link VARCHAR(50),
    Descrizione VARCHAR(50),
    CodiceTutorial INT,
    PRIMARY KEY(UsernameSpeaker),
    FOREIGN KEY(UsernameSpeaker) REFERENCES SPEAKER(Username),
    FOREIGN KEY(CodiceTutorial) REFERENCES P_TUTORIAL(CodicePresentazione)
)ENGINE="INNODB";

CREATE TABLE SPEAKER_TUTORIAL(
	UsernameSpeaker VARCHAR(30),
	CodiceTutorial INT,
	PRIMARY KEY(UsernameSpeaker, CodiceTutorial),
	FOREIGN KEY(UsernameSpeaker) REFERENCES SPEAKER(Username),
	FOREIGN KEY(CodiceTutorial) REFERENCES P_TUTORIAL(CodicePresentazione) 
)ENGINE="INNODB";

CREATE TABLE FAVORITE(
	Username VARCHAR(30),
	CodicePresentazione INT, 
	PRIMARY KEY(Username, CodicePresentazione),
	FOREIGN KEY(Username)REFERENCES UTENTE(Username),
	FOREIGN KEY(CodicePresentazione)REFERENCES PRESENTAZIONE(Codice)
)ENGINE="INNODB";

CREATE TABLE MESSAGGIO(
	UsernameMittente VARCHAR(30),
	Testo VARCHAR(200),
	Ts TIME,
	ChatID INT,
	PRIMARY KEY(UsernameMittente, Testo, Ts, ChatID),
	FOREIGN KEY(UsernameMittente) REFERENCES UTENTE(Username),
	FOREIGN KEY(ChatID) REFERENCES SESSIONE(Codice)
)ENGINE="INNODB";


# Stored Procedures

# Iserisce un nuovo utente
DELIMITER $
CREATE PROCEDURE InserisciUtente(IN Username VARCHAR(30), IN Password VARCHAR(30), IN Nome VARCHAR(25), IN Cognome VARCHAR(25), IN DataNascita DATE, IN Luogo VARCHAR(30)) 
BEGIN
	START TRANSACTION;
		INSERT INTO UTENTE(Username, Password, Nome, Cognome, DataNascita, Luogo) VALUES(Username, Password, Nome, Cognome, DataNascita, Luogo);
    COMMIT WORK;
END;
$ DELIITER ;

# Creazione di una conferenza da parte di un admin, che viene registrato ad essa automaticamente
DELIMITER $
CREATE PROCEDURE CreaConferenzaAdmin(IN Nome VARCHAR(30), IN UsernameAdmin VARCHAR(30), IN Acronimo VARCHAR(30), IN AnnoEdizione INT) 
BEGIN
	START TRANSACTION;
		IF(EXISTS(SELECT * FROM ADMIN WHERE ADMIN.Username = UsernameAdmin)) THEN
			INSERT INTO CONFERENZA(Nome, Acronimo, AnnoEdizione, Svolgimento) VALUES(Nome, Acronimo, AnnoEdizione, Svolgimento);
			INSERT INTO REGISTRAZIONE(Username, AcronimoConferenza, AnnoEdizione) VALUES(UsernameAdmin, Acronimo, AnnoEdizione);
            INSERT INTO CREAZIONE(UsernameAdmin, AcronimoConferenza, AnnoEdizione) VALUES(UsernameAdmin, Acronimo, AnnoEdizione);
		ELSE 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error on creaConferenzaAdmin: no admin found';
        END IF;
    COMMIT WORK;
END;
$ DELIMITER ;

# Aggiunge una nuova sponsorizzazione, se lo sponsor esiste già si inserisce solo 
# la sponsorizzazione, altrimenti si salva anche il nuovo sponsor
DELIMITER $
CREATE PROCEDURE AggiungiSponsorizzazione(IN NomeSponsor VARCHAR(30), IN AcronimoConferenza VARCHAR(30), IN Importo DOUBLE, IN Anno INT)
BEGIN
	IF(EXISTS(SELECT * FROM CONFERENZA AS C WHERE C.AnnoEdizione = Anno AND C.Acronimo = AcronimoConferenza)) THEN
		IF(NOT EXISTS(SELECT * FROM SPONSOR AS S WHERE S.Nome = NomeSponsor)) THEN
			INSERT INTO SPONSOR(Nome) VALUES(NomeSponsor);
			INSERT INTO SPONSORIZZAZIONE(NomeSponsor, AnnoEdizione, AcronimoConferenza, Importo) VALUES(NomeSponsor, Anno, AcronimoConferenza, Importo);
		ELSE 
			INSERT INTO SPONSORIZZAZIONE(NomeSponsor, AnnoEdizione, AcronimoConferenza, Importo) VALUES(NomeSponsor, Anno, AcronimoConferenza, Importo);
		END IF;
    ELSE 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error on AggiungiSponsorizzazione: no conference with that acronimo found';
    END IF;
END;
$ DELIMITER ;

# Inserisce le date di sovlgimento di una conferenza
DELIMITER $ 
CREATE PROCEDURE InserisciDateSvoglimento(IN AcronimoConferenza VARCHAR(30), IN Anno INT, IN DataInizio DATE, IN DataFine DATE)
BEGIN
	START TRANSACTION;
		BEGIN
            DECLARE i INT;
            DECLARE currentDate DATE;
            SET i = DataFine - DataInizio;
            SET currentDate = DataInizio;
			loop_label:  LOOP
				IF  i < 0 THEN 
					LEAVE  loop_label;
				END  IF;
				INSERT INTO DATASVOLGIMENTO(AcronimoConferenza, AnnoEdizione, Data) VALUES(AcronimoConferenza, Anno, currentDate);
				SET  i = i - 1;
				SET currentDate = DATE_ADD(currentDate, INTERVAL 1 DAY);
            END LOOP;
		END;
    COMMIT WORK;
END;
$ DELIMITER ;

# Crea una sessione per una conferenza, si controlla che la data della sessione sia una data che è 
# prevista per lo svolgimento della conferenza
DELIMITER $
CREATE PROCEDURE CreaSessione(IN AcronimoConferenza VARCHAR(30), IN Titolo VARCHAR(30), IN Anno INT ,IN Data DATE, IN OraInizio TIME, IN OraFine TIME, IN Link VARCHAR(50))
BEGIN
	START TRANSACTION;
        IF(EXISTS(SELECT * FROM DATASVOLGIMENTO AS D WHERE D.AcronimoConferenza = AcronimoConferenza AND D.Data = Data)) THEN
			SELECT @acronimo:=C.Acronimo, @anno:=C.AnnoEdizione
			FROM CONFERENZA AS C, PROGRAMMAGIORNALIERO AS D
			WHERE D.AcronimoConferenza = C.Acronimo AND D.AnnoEdizione = C.AnnoEdizione AND C.Acronimo = AcronimoConferenza AND Data = D.Data;
			INSERT INTO SESSIONE(AcronimoConferenza, Titolo, Data, Anno, OraInizio, OraFine, Link) VALUES(@acronimo, Titolo, Data, @anno, OraInizio, OraFine, Link);
        ELSE 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error on CreaSessione: the conference selected is not scheduled on this day';
        END IF;
    COMMIT WORK;
END;
$ DELIMITER ;

# Inserisce una nuova presentazione
DELIMITER $
CREATE PROCEDURE InserisciArticolo(IN Codice INT, IN CodiceSessione INT, IN OraInizio TIME, IN OraFine TIME, IN Titolo VARCHAR(30), IN NumeroPagine INT, IN UsernamePresenter VARCHAR(30))
BEGIN
	START TRANSACTION;
		IF(EXISTS(SELECT * FROM SESSIONE AS S WHERE S.Codice = CodiceSessione)) THEN
			INSERT INTO PRESENTAZIONE(Codice, CodiceSessione, OraInizio, OraFine, Tipologia) VALUES(Codice, CodiceSessione, OraInizio, OraFine, "ARTICOLO");
			IF(UsernamePresenter IS NOT NULL AND UsernamePresenter <> '') THEN
				INSERT INTO P_ARTICOLO(CodicePresentazione, Titolo, NumeroPagine, UsernamePresenter) VALUES(Codice, Titolo, NumeroPagine, UsernamePresenter);
			ELSE 
				INSERT INTO P_ARTICOLO(CodicePresentazione, Titolo, NumeroPagine) VALUES(Codice, Titolo, NumeroPagine);
			END IF;
		ELSE 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error on InserisciArticolo: the specified session has not been found ';
        END IF;
    COMMIT WORK;
END;
$ DELIMITER ;

# Inserisce una nuova presentazione
DELIMITER $
CREATE PROCEDURE InserisciTutorial(IN Codice INT, IN CodiceSessione INT, IN OraInizio TIME, IN OraFine TIME, IN Titolo VARCHAR(30), IN Abstract VARCHAR(500))
BEGIN
	START TRANSACTION;
		IF(EXISTS(SELECT * FROM SESSIONE AS S WHERE S.Codice = CodiceSessione)) THEN
			INSERT INTO PRESENTAZIONE(Codice, CodiceSessione, OraInizio, OraFine, Tipologia) VALUES(Codice, CodiceSessione, OraInizio, OraFine, "TUTORIAL");
			INSERT INTO P_TUTORIAL(CodicePresentazione, Titolo, Abstract) VALUES(Codice, Titolo, Abstract);
		ELSE 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error on InseriTutorial the specified session has not been found ';
		END IF;
    COMMIT WORK;
END;
$ DELIMITER ;

# Registra un utente ad una conferenza
DELIMITER $
CREATE PROCEDURE RegistrazioneConferenza(IN Username VARCHAR(30), IN Acronimo VARCHAR(30), IN Anno INT)
BEGIN
	START TRANSACTION;
		IF(EXISTS(SELECT * FROM UTENTE AS U WHERE U.Username = Username) AND EXISTS(SELECT * FROM CONFERENZA AS C WHERE C.Acronimo = Acronimo AND C.AnnoEdizione = Anno)) THEN
			INSERT INTO REGISTRAZIONE(Username, AcronimoConferenza, AnnoEdizione) VALUES(Username, Acronimo, Anno);
		ELSE 
			SELECT CONCAT("INPUT DATA INCORRECT") AS MESSAGE;
        END IF;
    COMMIT WORK;
END;
$ DELIMITER ;

# Cambia il ruolo di un utente esistente
DELIMITER $
CREATE PROCEDURE CambiaRuolo(IN username VARCHAR(30), IN newRole ENUM("ADMIN","SPEAKER","PRESENTER"))
BEGIN
	START TRANSACTION;
		IF(EXISTS(SELECT * FROM UTENTE WHERE UTENTE.Username = username)) THEN
			UPDATE UTENTE SET UTENTE.Tipologia = newRole WHERE(Utente.Username = username);
            IF(newRole = 'ADMIN') THEN
				INSERT INTO ADMIN(Username) VALUES(username);
			ELSEIF(newRole = 'PRESENTER') THEN
				INSERT INTO PRESENTER(Username) VALUES(username);
			ELSE 
				INSERT INTO SPEAKER(Username) VALUES(username);
            END IF;
		END IF;
    COMMIT WORK;
END;
$ DELIMITER ;

######## TRIGGER #########

# Incrementa il campo totale sponsorizzazioni ogni volta che si aggiunge uno sponsor per una determinata conferenza
DELIMITER $
CREATE TRIGGER IncrementaTotSponsorizzazioni
AFTER INSERT ON SPONSORIZZAZIONE
FOR EACH ROW
BEGIN
	UPDATE CONFERENZA SET totaleSponsorizzazioni = totaleSponsorizzazioni + 1 WHERE CONFERENZA.Acronimo = NEW.AcronimoConferenza;
END;
$ DELIMITER ;

# Incrementa il campo numero presentazini ogni volta che si aggiunge una presentazione ad una sessione
DELIMITER $
CREATE TRIGGER IncrementaTotPresentazioni
AFTER INSERT ON PRESENTAZIONE
FOR EACH ROW
BEGIN
	UPDATE SESSIONE SET SESSIONE.NumeroPresentazioni = SESSIONE.NumeroPresentazioni + 1 WHERE SESSIONE.Codice = NEW.CodiceSessione;
END;
$ DELIMITER ;

# Controlla che gli orari di inizio e di fine delle presentazioni non eccedano quelli della loro sessione
DELIMITER $
CREATE TRIGGER CheckOrariPresentazioni
BEFORE INSERT ON PRESENTAZIONE
FOR EACH ROW
BEGIN
    IF(NOT EXISTS (SELECT * FROM SESSIONE AS S WHERE S.Codice = NEW.CodiceSessione)) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error CodiceSessione Errato';
    END IF;

	IF(NEW.OraInizio < ALL (SELECT S.OraInizio FROM SESSIONE AS S WHERE S.Codice = NEW.CodiceSessione) OR (NEW.OraFine > ALL (SELECT S.OraFine FROM SESSIONE AS S WHERE S.Codice = NEW.CodiceSessione))) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error CheckOrariPresentazioni';
    END IF;
END;
$ DELIMITER ;

DELIMITER $
CREATE TRIGGER CheckAutoreArticolo
BEFORE INSERT ON P_ARTICOLO
FOR EACH ROW 
BEGIN
	IF(NEW.UsernamePresenter IS NOT NULL AND NEW.UsernamePresenter <> '') THEN
        IF(NOT EXISTS( SELECT * FROM P_ARTICOLO AS P WHERE P.CodicePresentazione = ANY(SELECT CodiceArticolo FROM SCRITTURA AS S WHERE NEW.CodicePresentazione = S.CodiceArticolo AND
		S.NomeAutore IN (SELECT Nome FROM UTENTE AS U WHERE U.Username = NEW.UsernamePresenter)))) THEN
		
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NON AUTORE';
		
        END IF;
    END IF;
END;
$ DELIMITER ;

DELIMITER $
CREATE TRIGGER CheckOrariMessaggi
BEFORE INSERT ON MESSAGGIO
FOR EACH ROW
BEGIN	
    IF(NOT EXISTS (SELECT * FROM SESSIONE AS S WHERE S.Codice = NEW.ChatId)) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error ChatId Errato';
    END IF;
	
	IF(NEW.Ts < ALL (SELECT S.OraInizio FROM SESSIONE AS S WHERE S.Codice = NEW.ChatId) OR (NEW.Ts > ALL (SELECT S.OraFine FROM SESSIONE AS S WHERE S.Codice = NEW.ChatId))) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error CheckOrariPresentazioni';
    END IF;
END;
$ DELIMITER ;


# Si vuole fare in modo che il numero di sequenza di ogni presentazione dipenda dalla 
# data e dall'ora della sessione in cui è programmata, perciò ogni numero di sequenza
# associato ad una presentazione farà fede alla sequenza propria della sua sessione
$ DELIMITER 
CREATE TRIGGER NumeriSequenza
BEFORE INSERT ON PRESENTAZIONE
FOR EACH ROW
BEGIN
	
END;
$ DELIMITER ;


# VIEW



