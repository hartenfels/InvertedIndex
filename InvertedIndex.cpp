#include <fstream>
#include <functional>
#include <list>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>
// to avoid conflict with a macro in perl
#undef seed
#include <algorithm>

// oh yeah C++
typedef std::back_insert_iterator<std::list<int> >           OutIt;
typedef std::list<int>::const_iterator                        InIt;
typedef std::function<OutIt (InIt, InIt, InIt, InIt, OutIt)> RowOp;

constexpr char  GROUP_SEP = '\035',
               RECORD_SEP = '\036',
                 UNIT_SEP = '\037';

class Row
{
public:

    void add_id(int id)
    {
        if (ids.empty() || ids.back() < id)
        {
            ids.push_back(id);
        }
        else if (ids.back() > id)
        {
            auto it = ids.begin();

            while (*it < id)
            {   ++it; }

            if (*it != id)
            {   ids.insert(it, id); }
        }
    }


    SV* listref()
    {
        AV* arr = newAV();

        for (int i : ids)
        {   av_push(arr, newSViv(i)); }

        return newRV_noinc(reinterpret_cast<SV*>(arr));
    }


    void op_with(const Row* rhs, RowOp op)
    {
        std::list<int> out;
        op(     ids.begin(),      ids.end(),
           rhs->ids.begin(), rhs->ids.end(),
           std::back_inserter(out));
        ids = out;
    }

    void and_with(const Row* rhs)
    {   op_with(rhs, std::set_intersection<InIt, InIt, OutIt>); }

    void  or_with(const Row* rhs)
    {   op_with(rhs, std::set_union       <InIt, InIt, OutIt>); }

    void but_with(const Row* rhs)
    {   op_with(rhs, std::set_difference  <InIt, InIt, OutIt>); }


    void stash(std::ofstream& out)
    {
        for (int i : ids)
        {   out << i << UNIT_SEP; }
    }


private:
    std::list<int> ids;

};


class InvertedIndex
{
public:

    int add_document(const char* document)
    {
        int id = documents.size();
        documents.push_back(document);
        return id;
    }


    void add_token(int id, const char* token)
    {
        indices[token].add_id(id);
    }


    void fetch(const char* token, Row* out) const
    {
        auto it = indices.find(token);
        if (it != indices.end())
        {   *out = it->second; }
    }


    const char* get_document(int id) const
    {
        return id >= 0 && id < documents.size()
             ? documents[id].c_str()
             : nullptr;
    }


    void stash(const char* path)
    {
        std::ofstream out(path);

        for (auto pair : indices)
        {
            out << pair.first << UNIT_SEP;
            pair.second.stash(out);
            out << RECORD_SEP;
        }
        out << GROUP_SEP;

        for (std::string& doc : documents)
        {   out << doc << UNIT_SEP; }
    }


    bool unstash(const char* path)
    {
        std::ifstream in(path);
        if (!in) { return false; }

        while (in.peek() != GROUP_SEP)
        {
            std::string token;
            std::getline(in, token, UNIT_SEP);
            while (in.peek() != RECORD_SEP)
            {
                std::string id;
                std::getline(in, id, UNIT_SEP);
                indices[token].add_id(atoi(id.c_str()));
            }
            in.ignore();
        }
        in.ignore();

        while (!in.eof())
        {
            std::string doc;
            std::getline(in, doc, UNIT_SEP);
            documents.push_back(doc);
        }

        return true;
    }


private:

    std::vector<std::string> documents;
    std::unordered_map<std::string, Row> indices;

};
