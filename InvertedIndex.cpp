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


template <typename T> static void
pack(const T& t, std::ofstream& out)
{   out.write(reinterpret_cast<const char*>(&t), sizeof(T)); }

template <typename T> static T
unpack(std::ifstream& in)
{
    T t;
    in.read(reinterpret_cast<char*>(&t), sizeof(T));
    return t;
}


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
        pack<std::list<int>::size_type>(ids.size(), out);
        for (int i : ids)
        {   pack<int>(i, out); }
    }

    void unstash(std::ifstream& in)
    {
        auto count = unpack<std::list<int>::size_type>(in);
        while (count--)
        {   ids.push_back(unpack<int>(in)); }
    }


private:
    std::list<int> ids;

};


class InvertedIndex
{
public:

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


    void stash(const char* path)
    {
        std::ofstream out(path);
        if (!out)
        {
            warn("Couldn't write to stash.\n");
            return;
        }

        for (auto pair : indices)
        {
            pack<std::string::size_type>(pair.first.size(), out);
            out.write(pair.first.c_str(), pair.first.size());
            pair.second.stash(out);
        }
    }


    bool unstash(const char* path)
    {
        std::ifstream in(path);
        if (!in)
        {
            warn("Couldn't read from stash.\n");
            return false;
        }

        while (in.peek() != EOF)
        {
            auto count = unpack<std::string::size_type>(in);
            std::string token(count, ' ');
            in.read(&token[0], count);
            indices[token].unstash(in);
        }

        return true;
    }


private:

    std::unordered_map<std::string, Row> indices;

};
